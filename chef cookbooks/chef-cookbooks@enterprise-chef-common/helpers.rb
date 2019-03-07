module EnterpriseChef
  module Helpers
    # Determine if this machine should be considered the bootstrap
    # server, based on topology, role, and explicit bootstrap
    # designation.
    #
    # Note that, for HA systems, it is possible for the bootstrap
    # server to *not* be the backend master server, due to a failover.
    # This method only looks at attributes, and does not inspect the
    # state of the server in any way.
    #
    # @param [Chef::Node] node
    # @return [Boolean]
    def self.is_bootstrap_server?(node)
      project_name = node['enterprise']['name']
      case node[project_name]['topology']
      when 'standalone', 'manual'
        true
      when 'tier'
        node[project_name]['role'] == 'backend'
      when 'ha'
        node_name = node['fqdn']
        !!(node[project_name]['servers'][node_name]['bootstrap'])
      end
    end

    # Determine if the node is the master for data storage replication
    # purposes.
    #
    # This will return `true` if the node is any of the following:
    #
    #   * A stand-alone EC install
    #   * A tier-topology backend machine
    #   * An HA topology backend keepalived master machine
    #
    # Any other machine will get `false`.
    #
    # @param node [Chef::Node] node
    # @return [Boolean]
    def self.is_data_master?(node)
      project_name = node['enterprise']['name']
      topology = node[project_name]['topology']
      role = node[project_name]['role']

      case topology
      when 'standalone'
        true # by definition
      when 'tier'
        role == 'backend'
      when 'ha'
        if role == 'backend'
          dir = node[project_name]['keepalived']['dir']
          cluster_status_file = "#{dir}/current_cluster_status"

          if File.exist?(cluster_status_file)
            File.open(cluster_status_file).read.chomp == 'master'
          else
            # If the file doesn't exist, then we are most likely doing
            # the initial setup, because keepalived must be configured
            # after everything else.  In this case, we'll consider
            # ourself the master if we're defined as the bootstrap
            # server
            is_bootstrap_server?(node)
          end
        else
          false # frontends can't be masters, by definition
        end
      end
    end

    # Determine if the machine is currently operating as the secondary
    # backend in an HA setup.
    #
    # @param node [Chef::Node] node
    # @return [Boolean]
    def self.backend_secondary?(node)
      ha?(node) && backend?(node) && !is_data_master?(node)
    end

    # Determine if the machine is set up for a standalone topology
    #
    # @param node [Chef::Node] node
    # @return [Boolean]
    def self.standalone?(node)
      project_name = node['enterprise']['name']
      node[project_name]['topology'] == 'standalone'
    end

    # Determine if the machine is set up for a tiered topology
    #
    # @param node [Chef::Node] node
    # @return [Boolean]
    def self.tier?(node)
      project_name = node['enterprise']['name']
      node[project_name]['topology'] == 'tier'
    end

    # Determine if the machine is set up for a HA topology
    #
    # @param node [Chef::Node] node
    # @return [Boolean]
    def self.ha?(node)
      project_name = node['enterprise']['name']
      node[project_name]['topology'] == 'ha'
    end

    # Determine if the machine should be running backend services,
    # regardless of topology.
    #
    # @param node [Chef::Node] node
    # @return [Boolean]
    def self.backend?(node)
      project_name = node['enterprise']['name']
      standalone?(node) || node[project_name]['role'] == 'backend'
    end

    # Determine if the machine should be running frontend services,
    # regardless of topology.
    #
    # @param node [Chef::Node] node
    # @return [Boolean]
    def self.frontend?(node)
      project_name = node['enterprise']['name']
      standalone?(node) || node[project_name]['role'] == 'frontend'
    end
  end
end
