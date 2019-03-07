=begin
#<
project provider configures a rundeck project

@action create  Create a rundeck project.
@action delete  Delete a rundeck project.

@section Examples

     # winrm example
     rundeck_server_project 'windows_servers' do
       executor({
         provider: 'overthere-winrm',
         config: {
          'winrm-auth-type'      => 'certificate',
          'winrm-protocol'       => 'https',
          'winrm-cert-trust'     => 'all',
          'winrm-hostname-trust' => 'all',
          'winrm-cert'           =>  [PKCS#12 key for Java]
         }
       })
       sources([{
        'type'            => 'url',
        'config.url'      => "http://url,
        'config.timeout'  => 30,
        'config.cache'    => true
       }])
       properties({
        'project.plugin.notification.PluginFoo.team' => 'bar',
       })
     end

     # ssh example
     rundeck_server_project 'linux_servers' do
       executor 'ssh'
       sources([{
        'type'            => 'url',
        'config.url'      => "http://chef-bridge/linux,
        'config.timeout'  => 30,
        'config.cache'    => true
      }])
      scm_import('config.strictHostKeyChecking' => 'no',
        'roles.0' => myrole,
        'roles.count' => 1,
        'config.url' => 'git@github.com:myaccount/rundeck-jobs.git',
        'trackedItems.count' => 0,
        'config.sshPrivateKeyPath' => 'keys/mykey')
      scm_export('config.strictHostKeyChecking' => 'no',
        'roles.0' => myrole,
        'roles.count' => 1,
        'config.url' => 'git@github.com:myaccount/rundeck-jobs.git',
        'config.sshPrivateKeyPath' => 'keys/mykey')
        nodes [{'name' => 'node1',
                'description' => 'node1',
                'tags' => '',
                'hostname' => 'node1.internal',
                'osArch' => 'amd64',
                'osFamily' => 'unix',
                'osName' => 'Linux',
                'osVersion' => '3.10.0-327.el7.x86_64'}
            ]
     end
#>
=end

# <> @property name Name of the project
property :project_name,
          String,
          name_property: true,
          regex: /^[-_+.a-zA-Z0-9]+$/

# <> @property executor Executor name + configuration. Could be a plain string (ssh) or complex hash configuration.
property :executor,
          [Symbol, Hash],
          default: :ssh,
          callbacks: ({
            must_contain_provider: lambda do |executor|
              executor.is_a?(Symbol) || !executor['provider'].nil? || !executor[:provider].nil?
            end,
            must_contain_config: lambda do |executor|
              executor.is_a?(Symbol) || (executor['config'] || executor[:config]).is_a?(Hash)
            end
          })

# <> @property scm-import setting of the project
property :scm_import,
          Hash,
          required: false

# <> @property scm-export setting of the project
property :scm_export,
          Hash,
          required: false

# <> @property nodes setting of the project
property :nodes,
          Array,
          required: false,
          default: []

# <> @property sources List of node sources
property :sources,
          Array,
          required: true,
          callbacks: ({
            must_be_an_array_of_hashes: lambda do |sources|
              sources.all? { |source| source.is_a?(Hash) }
            end,
            must_contain_type: lambda do |sources|
              sources.all? { |source| source['type'] || source[:type] }
            end
          })

# <> @property properties Hash of project properties
property :properties,
          Hash,
          required: false,
          default: {}

property :cookbook,
          String,
          default: 'rundeck-server'

action :create do
  %w(etc var).each do |d|
    directory ::File.join(node['rundeck_server']['datadir'], 'projects', new_resource.project_name, d) do
      user  'rundeck'
      group 'rundeck'
      mode '0770'
      recursive true
    end
  end

  properties = {}
  properties.merge!(new_resource.properties)
  properties['project.name'] = new_resource.project_name

  executor = new_resource.executor
  if executor.is_a? Symbol
    # Template executor config
    case executor
    when :ssh
      executor = {
        provider: 'jsch-ssh',
        config: {
          'ssh-authentication'  => 'privateKey',
          'ssh-keypath'         => "#{node['rundeck_server']['basedir']}/.ssh/id_rsa"
        }
      }
    when :winrm
      fail 'WinRM template not yet supported'
    else
      fail "Unknown executor template: #{new_resource.executor}"
    end
  end

  properties['service.NodeExecutor.default.provider'] = executor[:provider] || executor['provider']
  (executor[:config] || executor['config']).each do |key, value|
    properties["project.#{key}"] = value
  end

  # configure scm_export
  if new_resource.scm_export
    type = 'export'
    scm = scm_config(type, new_resource.name)
    scm['scm.export.config.committerEmail'] = '${user.email}'
    scm['scm.export.config.committerName'] = '${user.fullName}'
  end

  # configure scm_import
  if new_resource.scm_import
    type = 'import'
    scm = scm_config(type, new_resource.project_name)
    scm['scm.import.config.useFilePattern'] = true
    scm['scm.import.config.filePattern'] = '.*\\\.yaml'
  end

  if new_resource.scm_export || new_resource.scm_import
    new_resource.scm_export.each do |k, v|
      scm["scm.#{type}.#{k}"] = v
    end

    directory ::File.join(node['rundeck_server']['datadir'], 'projects', new_resource.project_name, 'scm') do
      user     'rundeck'
      group    'rundeck'
      mode     '0770'
    end

    template ::File.join(node['rundeck_server']['datadir'], 'projects', new_resource.project_name, 'etc', "scm-#{type}.properties") do
      source   'properties.erb'
      user     'rundeck'
      group    'rundeck'
      mode     '0660'
      cookbook new_resource.cookbook
      variables(properties: scm)
    end
  end

  new_resource.sources.each_with_index do |source, i|
    source.each do |k, v|
      properties["resources.source.#{i + 1}.#{k}"] = v
    end
    properties["resources.source.#{i + 1}.config.file"] = ::File.join(node['rundeck_server']['datadir'], 'projects', new_resource.project_name, 'etc', 'resources.xml')
  end
  properties['service.FileCopier.default.provider'] = 'jsch-scp'

  template ::File.join(node['rundeck_server']['datadir'], 'projects', new_resource.project_name, 'etc', 'project.properties') do
    source   'properties.erb'
    user     'rundeck'
    group    'rundeck'
    mode     '0660'
    cookbook new_resource.cookbook
    variables(properties: properties)
  end

  template ::File.join(node['rundeck_server']['datadir'], 'projects', new_resource.project_name, 'etc', 'resources.xml') do
    source   'resources.xml.erb'
    user     'rundeck'
    group    'rundeck'
    mode     '0660'
    cookbook new_resource.cookbook
    variables(nodes: new_resource.nodes)
  end
end

action :delete do
  directory ::File.join(node['rundeck_server']['datadir'], 'projects', new_resource.project_name) do
    recursive true
    action :delete
  end
end

# SCM common settings
def scm_config(type, name)
  scm_config = {}
  scm_config["scm.#{type}.type"] = "git-#{type}"
  scm_config["scm.#{type}.username"] = 'rundeck'
  scm_config["scm.#{type}.config.branch"] = 'master'
  scm_config["scm.#{type}.config.strictHostKeyChecking"] = 'yes'
  scm_config["scm.#{type}.config.pathTemplate"] = '${job.group}${job.name}-${job.id}.${config.format}'
  scm_config["scm.#{type}.config.dir"] = ::File.join(node['rundeck_server']['datadir'], 'projects', name, 'scm')
  scm_config["scm.#{type}.config.format"] = 'yaml'
  scm_config["scm.#{type}.config.importUuidBehavior"] = 'preserve'
  scm_config["scm.#{type}.config.fetchAutomatically"] = true
  scm_config["scm.#{type}.enabled"] = true
  scm_config
end
