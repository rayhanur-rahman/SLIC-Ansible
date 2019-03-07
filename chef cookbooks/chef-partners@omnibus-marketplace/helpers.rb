require 'resolv'
require 'net/http'
require 'timeout'
require 'securerandom'
require 'yaml'

class Marketplace
  module Helpers
    def motd_action
      node['chef-marketplace']['motd']['enabled'] ? :create : :delete
    end

    def reporting_partition_action
      node['chef-marketplace']['reporting']['cron']['enabled'] ? :create : :delete
    end

    def actions_trimmer_action
      node['chef-marketplace']['analytics']['trimmer']['enabled'] ? :create : :delete
    end

    def current_user_directories
      Etc::Passwd.each_with_object({}) do |user, memo|
        next if %w(halt sync shutdown).include?(user.name) ||
                user.shell =~ %r{(/sbin/nologin|/bin/false)}
        memo[user.name] = user.dir
      end
    end

    def system_ssh_keys
      %w(key key.pub dsa_key dsa_key.pub rsa_key.pub rsa_key).map do |key|
        "/etc/ssh/ssh_host_#{key}"
      end
    end

    def current_sudoers
      Dir['/etc/sudoers.d/*'].delete_if { |entry| entry =~ /cloud-init/ }
    end

    def cloud_cfg_gecos
      case node['chef-marketplace']['platform']
      when 'aws' then 'Ec2 User'
      when 'azure' then 'Ubuntu'
      when 'openstack' then 'OpenStack User'
      when 'oracle' then 'Oracle User'
      end
    end

    def cloud_cfg_default_user
      node['chef-marketplace']['platform'] == 'azure' ? 'ubuntu' : node['chef-marketplace']['user']
    end

    def cloud_cfg_ssh_pwauth
      node['chef-marketplace']['platform'] == 'azure' ? true : false
    end

    def cloud_cfg_locale_configfile
      node['platform_family'] == 'rhel' ? '/etc/sysconfig/i18n' : '/etc/default/locale'
    end

    def cloud_cfg_distro
      node['platform_family'] == 'rhel' ? 'rhel' : node['platform']
    end

    def cron_package
      case node['platform']
      when 'redhat', 'centos', 'oracle' then 'cronie'
      when 'debian', 'ubuntu' then 'cron'
      end
    end

    def default_package_mirror_uri
      case node['platform']
      when 'redhat' then 'http://mirrorlist.centos.org'
      when 'centos' then 'http://mirrorlist.centos.org'
      when 'ubuntu' then 'http://us.archive.ubuntu.com/ubuntu/'
      end
    end

    # When the Chef Server is in a private VPC some recipes will wait for a very
    # long time for yum to timeout and then eventually crash. Instead, we won't
    # worry about package installs/removals in that environment.
    def mirrors_reachable?(mirror = nil)
      mirror ||= default_package_mirror_uri
      return node['chef-marketplace']['mirrors_reachable'] if node['chef-marketplace'].attribute?('mirrors_reachable')

      # check whether or not outbound traffic is disabled
      if outbound_traffic_disabled?
        return node.default['chef-marketplace']['mirrors_reachable'] = false
      end

      # check if the hostname is resolvable
      uri = URI(mirror)
      Resolv.getaddress(uri.host)

      # check if the mirror is reachable
      Timeout.timeout(2) do
        res = Net::HTTP.get_response(uri)
        node.default['chef-marketplace']['mirrors_reachable'] = res.is_a?(Net::HTTPSuccess)
      end

      node['chef-marketplace']['mirrors_reachable']
    rescue
      node.default['chef-marketplace']['mirrors_reachable'] = false
    end

    def outbound_traffic_disabled?
      return false if node['chef-marketplace']['override_outbound_traffic']
      node['chef-marketplace']['disable_outbound_traffic']
    end

    def security_enabled?
      node['chef-marketplace'].attribute?('security') && node['chef-marketplace']['security']['enabled']
    end

    def chef_server_configured?
      File.exist?('/etc/opscode/chef-server-running.json')
    end

    def delivery_configured?
      File.exist?('/etc/delivery/delivery-running.json')
    end

    def analytics_configured?
      File.exist?('/etc/opscode-analytics/opscode-analytics-running.json')
    end

    def compliance_configured?
      File.exist?('/etc/chef-compliance/chef-compliance-running.json')
    end

    def frontend_url
      "https://#{node['chef-marketplace']['api_fqdn']}"
    end

    def analytics_url
      "#{frontend_url}:#{node['chef-marketplace']['analytics']['ssl_port']}"
    end

    def motd_variables
      vars = {
        doc_url: node['chef-marketplace']['documentation']['url'],
        support_email: node['chef-marketplace']['support']['email'],
        role: node['chef-marketplace']['role'],
        frontend_url: frontend_url
      }

      case node['chef-marketplace']['role']
      when 'server', 'aio'
        vars[:role_name] = 'Chef Server'
        vars[:setup_wizard_url] = "#{frontend_url}/signup"
      when 'analytics'
        vars[:role_name] = 'Chef Analytics'
        vars[:setup_wizard_url] = 'chef-marketplace-ctl setup'
      when 'compliance'
        vars[:role_name] = 'Chef Compliance'
        vars[:setup_wizard_url] = "#{frontend_url}/#/setup"
      when 'automate'
        vars[:role_name] = 'Chef Automate'
        vars[:setup_wizard_url] = "#{frontend_url}/biscotti/setup"
      end

      vars
    end

    # Returns an array of hashes of which omnibus commands should be enabled/disabled
    def omnibus_commands
      service_dir = '/opt/chef-marketplace/embedded/service'

      enabled_commands = %w(
        setup.rb
        hostname.rb
        test.rb
        upgrade.rb
        trim_actions_db.rb
        register_node.rb
        prepare_for_publishing.rb
        show_instance_id.rb
      )
      disabled_commands = []

      case node['chef-marketplace']['role']
      when 'server', 'compliance'
        disabled_commands << enabled_commands.delete('trim_actions_db.rb')
      when 'aio', 'analytics'
        # Keep em all
      when 'automate'
        disabled_commands << enabled_commands.delete('trim_actions_db.rb')
        disabled_commands << enabled_commands.delete('register_node.rb')
      end

      enabled_commands.map! do |cmd|
        { source: "#{service_dir}/chef-marketplace-ctl/#{cmd}",
          destination: "#{service_dir}/omnibus-ctl/#{cmd}",
          action: :create
        }
      end

      disabled_commands.map! do |cmd|
        { source: "#{service_dir}/chef-marketplace-ctl/#{cmd}",
          destination: "#{service_dir}/omnibus-ctl/#{cmd}",
          action: :delete
        }
      end

      enabled_commands + disabled_commands
    end

    def biscotti_config
      {
        'production' => {
          'biscotti' => {
            'message' => node['chef-marketplace']['biscotti']['message'],
            'uuid' => node['chef-marketplace']['biscotti']['uuid'],
            'uuid_type' => node['chef-marketplace']['biscotti']['uuid_type'],
            'token' => node['chef-marketplace']['biscotti']['token'],
            'doc_href' => node['chef-marketplace']['documentation']['url'],
            'auth_required' => node['chef-marketplace']['biscotti']['auth_required'],
            'cloud_marketplace' => cloud_marketplace_name,
            'redirect_path' => node['chef-marketplace']['biscotti']['redirect_path']
          },
          'platform' => node['chef-marketplace']['platform'],
          'frontend_url' => frontend_url,
          'automate' => {
            'credentials' => node['chef-marketplace']['automate']['credentials'].to_h
          }
        }
      }
    end

    def cloud_marketplace_name
      case node['chef-marketplace']['platform']
      when 'aws' then 'AWS Marketplace'
      when 'azure' then 'Azure Marketplace'
      end
    end

    def analytics_state_files
      %w{
        /var/opt/opscode-analytics/bootstrapped
        /var/opt/opscode-analytics/actions/config/secrets.yml
        /var/opt/opscode-analytics/actions/config/database.yml
        /var/opt/opscode-analytics/actions-messages/sys.config
        /var/opt/opscode-analytics/notifier/sys.config
        /var/opt/opscode-analytics/notifier_config/sys.config
        /var/opt/opscode-analytics/storm/topology/alaska/alaska.conf
        /var/opt/opscode-analytics/storm/topology/alaska/truststore.jks
        /var/opt/opscode/nginx/etc/nginx.d/analytics.conf
        /etc/opscode-analytics/actions-source.json
        /etc/opscode-analytics/alaska-tools.rb
        /etc/opscode-analytics/opscode-analytics-running.json
        /etc/opscode-analytics/opscode-analytics-secrets.json
        /etc/opscode-analytics/webui_priv.pem
        /opt/opscode-analytics/embedded/service/actions_messages/sys.config
        /opt/opscode-analytics/embedded/service/actions/config/initializers/assets.rb
        /opt/opscode-analytics/embedded/service/notifier/sys.config
        /opt/opscode-analytics/embedded/service/notifier_config/sys.config
        /opt/opscode-analytics/embedded/bin/storm
        /opt/opscode-analytics/embedded/bin/alaska
      }
    end

    def analytics_state_directories
      %w{
        /opt/opscode-analytics/sv
        /opt/opscode-analytics/init
        /opt/opscode-analytics/service
        /var/opt/opscode-analytics/postgresql
        /var/opt/opscode-analytics/ssl
        /var/opt/opscode-analytics/zookeeper/data
      }
    end

    def server_state_files
      %w{
        /etc/opscode/webui_pub.pem
        /etc/opscode/worker-public.pem
        /etc/opscode/chef-server-running.json
        /etc/opscode/pivotal.pem
        /etc/opscode/private-chef-secrets.json
        /etc/opscode/webui_priv.pem
        /etc/opscode/worker-private.pem
        /etc/opscode-reporting/opscode-reporting-running.json
        /etc/opscode-reporting/opscode-reporting-secrets.json
        /etc/chef-manage/secrets.rb
        /opt/opscode/embedded/service/oc_bifrost/sys.config
        /opt/opscode/embedded/service/oc_id/config/settings/production.yml
        /opt/opscode/embedded/service/oc_id/config/initializers/secret_token.rb
        /opt/opscode/embedded/service/oc_id/config/database.yml
        /opt/opscode/embedded/service/opscode-solr4/jetty/etc/jetty.xml
        /opt/opscode/embedded/service/opscode-solr4/jetty/contexts/solr-jetty-context.xml
        /opt/opscode/embedded/service/opscode-erchef/sys.config
        /opt/opscode/embedded/service/bookshelf/sys.config
        /opt/opscode/embedded/service/chef-server-bootstrap/bootstrapper-config/pivotal.yml
        /opt/opscode/embedded/service/opscode-chef-mover/sys.config
        /opt/opscode-reporting/embedded/service/opscode-reporting/db/permissions.sql
        /opt/opscode-reporting/embedded/service/opscode-reporting/etc/sys.config
        /opt/chef-manage/embedded/service/chef-manage/config/settings/production.yml
        /opt/chef-manage/embedded/service/chef-manage/config/newrelic.yml
        /var/opt/opscode/bootstrapped
        /var/opt/opscode/bookshelf/sys.config
        /var/opt/opscode/oc_bifrost/sys.config
        /var/opt/opscode/opscode-account-mover/sys.config
        /var/opt/opscode/opscode-erchef/sys.config
        /var/opt/opscode-reporting/bootstrapped
        /var/opt/opscode-reporting/etc/sys.config
        /var/opt/chef-manage/etc/chef-manage-running.json
        /var/opt/chef-manage/etc/settings.yml
      }
    end

    def server_state_directories
      %w{
        /opt/opscode/sv
        /opt/opscode/service
        /opt/opscode/init
        /opt/chef-manage/sv
        /opt/chef-manage/init
        /opt/chef-manage/service
        /var/opt/opscode/nginx/ca
        /var/opt/opscode/nginx/scripts
        /var/opt/opscode/pc_id/config
        /var/opt/opscode/opscode-account-mover/data
        /var/opt/opscode/opscode-expander/etc
        /var/opt/opscode/opscode-solr4
        /var/opt/opscode/postgresql
        /var/opt/opscode/rabbitmq
        /var/opt/opscode/redis_lb
        /var/opt/opscode/upgrades
        /var/opt/opscode/local-mode-cache
      }
    end

    def automate_state_files
      # TODO: more app configs
      %w{
        /etc/delivery/builder.pem
        /etc/delivery/builder.pub
        /etc/delivery/delivery.pem
        /etc/delivery/delivery.pup
        /etc/delivery/delivery-running.json
        /etc/delivery/delivery-secrets.json
      }
    end

    def automate_state_directories
      %w{
        /opt/delivery/sv
        /opt/delivery/service
        /opt/delivery/init
        /var/opt/delivery/census
        /var/opt/delivery/delivery
        /var/opt/delivery/elasticsearch
        /var/opt/delivery/elasticsearch_backups
        /var/opt/delivery/local-mode-cache
        /var/opt/delivery/nginx/ca
        /var/opt/delivery/postgresql
        /var/opt/delivery/rabbitmq
      }
    end

    def marketplace_state_files
      %w{
        /etc/chef-marketplace/chef-marketplace-secrets.json
      }
    end

    def compliance_state_files
      %w{
        /etc/chef-compliance/chef-compliance-running.json
        /etc/chef-compliance/chef-compliance-secrets.json
        /etc/chef-compliance/server-config.json
      }
    end

    def compliance_state_directories
      %w{
        /opt/chef-compliance/sv
        /opt/chef-compliance/init
        /opt/chef-compliance/service
        /var/opt/chef-compliance/postgresql
        /var/opt/chef-compliance/ssl
      }
    end

    def biscotti_token_hmac
      digest = OpenSSL::Digest.new("sha1")
      OpenSSL::HMAC.hexdigest(digest,
                              node["chef-marketplace"]["biscotti"]["token"],
                              node["chef-marketplace"]["biscotti"]["uuid"])
    end
  end
end

if defined?(Chef)
  Chef::Recipe.send(:include, Marketplace::Helpers)
  Chef::Provider.send(:include, Marketplace::Helpers)
  Chef::Resource.send(:include, Marketplace::Helpers)
  Chef::ResourceDefinition.send(:include, Marketplace::Helpers)
end
