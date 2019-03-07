require 'uri'

actions :install
default_action :install

property :src_url,
  String,
  default: 'https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz'

action :install do
  unless tools_installed?
    converge_by 'install cloudformation tools' do
      package 'epel-release'
      package 'python-pip'

      directory '/opt/aws/bin' do
        recursive true
      end

      remote_file '/tmp/cfn.tar.gz' do
        source src_url
      end

      bash 'build and install tools' do
        cwd "/tmp"
        code <<-EOH
          tar xpf cfn.tar.gz
          cd aws-cfn-bootstrap-*
          python setup.py build
          python setup.py install
        EOH
      end

      link "/etc/init.d/cfn-hup" do
        to "/usr/init/redhat/cfn-hup"
      end

      file "/usr/init/redhat/cfn-hup" do
        mode 0775
      end

      cfn_binary_names.each do |cmd|
        link ::File.join("/opt/aws/bin", cmd) do
          to ::File.join("/usr/bin", cmd)
        end
      end
    end
  end
end

action_class do
  def cfn_binary_names
    %w(
      cfn-hup
      cfn-init
      cfn-signal
      cfn-elect-cmd-leader
      cfn-get-metadata
      cfn-send-cmd-event
      cfn-send-cmd-result
    )
  end

  def tools_installed?
    cfn_binary_names.all? do |t|
      begin
        ::File.executable?(::File.join('/opt/aws/bin', t))
      rescue
        false
      end
    end
  end
end
