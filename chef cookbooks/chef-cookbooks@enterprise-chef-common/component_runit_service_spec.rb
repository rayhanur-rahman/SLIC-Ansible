require 'spec_helper'

describe 'component_runit_service' do
  step_into :component_runit_service
  platform 'ubuntu'
  default_attributes['enterprise']['name'] = 'awesomeproduct'
  default_attributes['runit']['sv_bin'] = '/opt/runit'
  default_attributes['runit']['sv_dir'] = '/var/opt/runit'

  context 'action :enable' do
    context '(defaults)' do
      default_attributes['awesomeproduct']['sweetservice']['log_directory'] = '/var/log/awesomeproduct/sweetservice'
      default_attributes['awesomeproduct']['sweetservice']['log_rotation']['num_to_keep'] = 42
      default_attributes['awesomeproduct']['sweetservice']['log_rotation']['file_maxbytes'] = 8675309

      recipe do
        component_runit_service 'sweetservice' do
          package 'awesomeproduct'
        end
      end

      it 'enable is the default action' do
        expect(chef_run).to enable_component_runit_service('sweetservice')
      end

      it 'creates a resource to restart the component\'s svlog service, but does not run it yet' do
        expect(chef_run).to nothing_execute('restart_sweetservice_log_service')
          .with(command: '/opt/runit restart /var/opt/runit/sweetservice/log')
      end

      it 'renders the svlogd template' do
        expect(chef_run).to create_template('/var/log/awesomeproduct/sweetservice/config').with(
          owner: 'root',
          group: 'root',
          mode: '0644',
          source: 'config.svlogd',
          variables: {
            svlogd_num: 42,
            svlogd_size: 8675309,
          }
        )
      end

      it 'notifies the svlog service restarter to run if the svlog template renders with changes' do
        expect(chef_run.template('/var/log/awesomeproduct/sweetservice/config')).to notify('execute[restart_sweetservice_log_service]')
      end

      it 'enables a runit service' do
        expect(chef_run).to enable_runit_service('sweetservice').with(
          retries: 20,
          options: {
            log_directory: '/var/log/awesomeproduct/sweetservice',
          }
        )
      end
    end

    context 'when alternate location is given for the log directory via property' do
      default_attributes['awesomeproduct']['logelsewhere']['log_directory'] = 'should_not_see_this_attr_default'
      default_attributes['awesomeproduct']['logelsewhere']['log_rotation']['num_to_keep'] = 42
      default_attributes['awesomeproduct']['logelsewhere']['log_rotation']['file_maxbytes'] = 8675309

      recipe do
        component_runit_service 'logelsewhere' do
          package 'awesomeproduct'
          log_directory '/var/log/somewhere_else'
        end
      end

      it 'renders the svlogd template to the alternate location' do
        expect(chef_run).to create_template('/var/log/somewhere_else/config')
      end

      it 'enables a runit service with the alternate log directory' do
        expect(chef_run).to enable_runit_service('logelsewhere').with(
          options: {
            log_directory: '/var/log/somewhere_else',
          }
        )
      end
    end

    context 'when log retention is customized via properties' do
      default_attributes['awesomeproduct']['lotsoflogs']['log_directory'] = '/var/log/awesomeproduct/lotsoflogs'
      default_attributes['awesomeproduct']['lotsoflogs']['log_rotation']['num_to_keep'] = 'should_not_see_this_attr_default'
      default_attributes['awesomeproduct']['lotsoflogs']['log_rotation']['file_maxbytes'] = 'should_not_see_this_attr_default'

      recipe do
        component_runit_service 'lotsoflogs' do
          package 'awesomeproduct'
          svlogd_num 1000
          svlogd_size 6060842
        end
      end

      it 'renders the svlogd template with the given retention settings' do
        expect(chef_run).to create_template('/var/log/awesomeproduct/lotsoflogs/config').with(
          variables: {
            svlogd_num: 1000,
            svlogd_size: 6060842,
          }
        )
      end
    end

    context 'when control signals are customized via properties' do
      default_attributes['awesomeproduct']['controlsignals']['log_directory'] = '/var/log/awesomeproduct/controlsignals'
      default_attributes['awesomeproduct']['controlsignals']['log_rotation']['num_to_keep'] = 42
      default_attributes['awesomeproduct']['controlsignals']['log_rotation']['file_maxbytes'] = 8675309

      recipe do
        component_runit_service 'controlsignals' do
          package 'awesomeproduct'
          control ['t']
        end
      end

      it 'enables a runit service' do
        expect(chef_run).to enable_runit_service('controlsignals').with(
          control: ['t']
        )
      end
    end

    context 'when arbitrary runit_service properties are included via properties' do
      default_attributes['awesomeproduct']['arbitraryrunit']['log_directory'] = '/var/log/awesomeproduct/arbitraryrunit'
      default_attributes['awesomeproduct']['arbitraryrunit']['log_rotation']['num_to_keep'] = 42
      default_attributes['awesomeproduct']['arbitraryrunit']['log_rotation']['file_maxbytes'] = 8675309

      recipe do
        component_runit_service 'arbitraryrunit' do
          package 'awesomeproduct'
          runit_attributes(log_processor: 'arbitrariness')
        end
      end

      it 'passes the custom runit attributes to the runit service' do
        expect(chef_run).to enable_runit_service('arbitraryrunit').with(
          log_processor: 'arbitrariness'
        )
      end
    end

    context 'keepalive management in an HA topology' do
      default_attributes['awesomeproduct']['topology'] = 'ha'
      default_attributes['awesomeproduct']['haservice']['log_directory'] = '/var/log/awesomeproduct/haservice'
      default_attributes['awesomeproduct']['haservice']['log_rotation']['num_to_keep'] = 42
      default_attributes['awesomeproduct']['haservice']['log_rotation']['file_maxbytes'] = 8675309

      recipe do
        component_runit_service 'haservice' do
          package 'awesomeproduct'
        end
      end

      context 'by default' do
        it { is_expected.to delete_file('/var/opt/runit/haservice/keepalive_me') }
        it { is_expected.to delete_file('/var/opt/runit/haservice/down') }
      end

      context 'when HA is disabled for the component' do
        context 'via node attributes' do
          default_attributes['awesomeproduct']['haservice']['ha'] = false

          it { is_expected.to delete_file('/var/opt/runit/haservice/keepalive_me') }
          it { is_expected.to delete_file('/var/opt/runit/haservice/down') }
        end

        context 'via resource parameters' do
          recipe do
            component_runit_service 'haservice' do
              package 'awesomeproduct'
              ha false
            end
          end

          it { is_expected.to delete_file('/var/opt/runit/haservice/keepalive_me') }
          it { is_expected.to delete_file('/var/opt/runit/haservice/down') }
        end
      end

      context 'when HA is enabled for the component' do
        context 'via node attributes' do
          default_attributes['awesomeproduct']['haservice']['ha'] = true

          it { is_expected.to create_file('/var/opt/runit/haservice/keepalive_me') }
          it { is_expected.to create_file('/var/opt/runit/haservice/down') }
        end

        context 'via resource parameters' do
          recipe do
            component_runit_service 'haservice' do
              package 'awesomeproduct'
              ha true
            end
          end

          it { is_expected.to create_file('/var/opt/runit/haservice/keepalive_me') }
          it { is_expected.to create_file('/var/opt/runit/haservice/down') }
        end
      end
    end
  end

  context 'action :down' do
    recipe do
      component_runit_service 'stopme' do
        package 'awesomeproduct'
        action :down
      end
    end

    it { is_expected.to stop_runit_service('stopme') }
  end

  context 'delegating some actions to the runit_service resource' do
    [:start, :restart, :stop, :reload, :disable].each do |action_name|
      context "action :#{action_name}" do
        recipe do
          component_runit_service 'passalong' do
            package 'awesomeproduct'
            action action_name
          end
        end

        it { is_expected.to send("#{action_name}_runit_service".to_sym, 'passalong') }
      end
    end
  end
end
