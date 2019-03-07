require_relative '../spec_helper'

describe 'rundeck-server' do
  mock_web_xml 'wrong_user'

  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'download winrm plugin' do
    expect(chef_run).to create_remote_file('winrm')
      .with_path('/var/lib/rundeck/libext/winrm.jar')
      .with_checksum(nil)
  end

  it 'enable rundeckd service' do
    expect(chef_run).to enable_service('rundeckd')
  end

  it 'create template' do
    expect(chef_run).to create_template('rundeck-jaas')
  end

  it 'check default template content' do
    expect(chef_run).to render_file('rundeck-jaas')
      .with_content('org.eclipse.jetty.jaas.spi.PropertyFileLoginModule')
  end

  it 'simple default admin aclpolicy yaml content' do
    expect(chef_run).to render_file('rundeck-aclpolicy-admin')
      .with_content(/- allow: ['"]\*['"]/)
  end

  it 'configure web.xml' do
    expect(chef_run).to run_ruby_block('web-xml-update')
  end

  it 'check JVM options' do
    expect(chef_run).to render_file('rundeck-profile')
      .with_content('-XX:MaxPermSize=256m')
  end

  it 'create template realm.properties' do
    expect(chef_run).to create_template('realm.properties')
  end

  it 'create template log4j.properties' do
    expect(chef_run).to create_template('/etc/rundeck/log4j.properties')
  end
end

describe 'rundeck-server' do
  mock_web_xml

  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.normal['rundeck_server']['plugins']['winrm']['checksum'] =
        '54500ae1db500f7be2e0468d6f464c1f7f28c5aa4c7c2e7f0cb3a5cfa0386824'
      node.normal['rundeck_server']['jvm']['Xmx1024m'] = false
    end.converge(described_recipe)
  end

  it 'download winrm plugin with optional checksum' do
    expect(chef_run).to create_remote_file('winrm')
      .with_path('/var/lib/rundeck/libext/winrm.jar')
      .with_checksum('54500ae1db500f7be2e0468d6f464c1f7f28c5aa4c7c2e7f0cb3a5cfa0386824')
  end

  it 'does not configure web.xml' do
    expect(chef_run).to_not run_ruby_block('web-xml-update')
  end

  it 'disable JVM options when set to false' do
    expect(chef_run).to render_file('rundeck-profile')
    expect(chef_run).not_to render_file('rundeck-profile')
      .with_content('-Xmx1024m')
  end
end
