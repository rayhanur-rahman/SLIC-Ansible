module DmonAgent
  # Module with helper function for dmon_agent cookbook
  module Helper
    def skip_installation?
      unless node['cloudify']['properties'].key? 'monitoring'
        msg = 'Monitoring property is not present. This indicates that TOSCA '\
          'library contains a bug. Please report this to developers.'
        Chef::Application.fatal!(msg, 1)
      end

      unless node['cloudify']['properties']['monitoring']['enabled']
        Chef::Log.info('Monitoring is disabled. Skipping recipe.')
        return true
      end

      false
    end
  end
end
