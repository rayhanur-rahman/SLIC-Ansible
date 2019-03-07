module Moonshot
  module Commands
    class Deploy < Moonshot::Command
      self.usage = 'deploy VERSION'
      self.description = 'Deploy a versioned release to the environment'

      def parser
        parser = super

        parser.on('--[no-]interactive', TrueClass, 'Use interactive prompts.') do |v|
          Moonshot.config.interactive = v
        end
      end

      def execute(version_name)
        controller.deploy_version(version_name)
      end
    end
  end
end
