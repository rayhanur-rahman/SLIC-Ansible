require 'seth/ceth'

class Seth
  class ceth
    class Serve < ceth
      option :repo_mode,
        :long => '--repo-mode MODE',
        :description => "Specifies the local repository layout.  Values: static (only environments/roles/data_bags/cookbooks), everything (includes nodes/clients/users), hosted_everything (includes acls/groups/etc. for Enterprise/Hosted Seth).  Default: everything/hosted_everything"

      option :seth_repo_path,
        :long => '--seth-repo-path PATH',
        :description => 'Overrides the location of seth repo. Default is specified by seth_repo_path in the config'

      option :seth_zero_host,
        :long => '--seth-zero-host IP',
        :description => 'Overrides the host upon which seth-zero listens. Default is 127.0.0.1.'

      def configure_seth
        super
        Seth::Config.local_mode = true
        Seth::Config[:repo_mode] = config[:repo_mode] if config[:repo_mode]

        # --seth-repo-path forcibly overrides all other paths
        if config[:seth_repo_path]
          Seth::Config.seth_repo_path = config[:seth_repo_path]
          %w(acl client cookbook container data_bag environment group node role user).each do |variable_name|
            Seth::Config.delete("#{variable_name}_path".to_sym)
          end
        end
      end

      def run
        begin
          server = Seth::Application.seth_zero_server
          output "Serving files from:\n#{server.options[:data_store].seth_fs.fs_description}"
          server.stop
          server.start(stdout) # to print header
        ensure
          server.stop
        end
      end
    end
  end
end
