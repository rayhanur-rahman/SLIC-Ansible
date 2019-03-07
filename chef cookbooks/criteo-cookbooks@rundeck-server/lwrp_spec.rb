require_relative '../spec_helper'

describe 'rundeck-test::project' do
  mock_web_xml

  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      step_into: ['rundeck_server_project']
    ).converge(described_recipe)
  end

  it 'creates project properties file' do
    expect(chef_run).to render_file('/var/rundeck/projects/test-project-ssh/etc/project.properties')
      .with_content('http\://chefserver_bridge\:9980')
  end
end

describe 'rundeck-test::job' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      step_into: ['rundeck_server_job']
    ).converge(described_recipe)
  end

  let(:response) do
    r = double('api-response')
    allow(r).to receive(:to_h) { { 'failed' => { 'count' => 0 } } }
    r
  end

  context 'job does not exist' do
    it 'call api to create a job' do
      require 'yaml'
      job = { 'name' => 'test-job2', 'id' => 'abcde' }
      yaml = [job].to_yaml
      client = double('rundeck-client')
      expect(Rundeck::Client).to receive(:new).and_return(client)
      expect(client).to receive(:export_jobs).with('project', 'yaml', kind_of(Hash)) { yaml }
      expect(client).to receive(:import_jobs).and_return(response)
      chef_run # evaluate chef_run
    end
  end

  context 'job exists but is different' do
    it 'call api to modify a job' do
      job = { 'name' => 'test-job', 'id' => 'abcde', 'uuid' => 'abcde' }
      yaml = [job].to_yaml
      client = double('rundeck-client')
      expect(Rundeck::Client).to receive(:new).and_return(client)
      expect(client).to receive(:export_jobs).with('project', 'yaml', kind_of(Hash)) { yaml }
      expect(client).to receive(:import_jobs).with(
        "- description: ''\n  loglevel: INFO\n  sequence:\n    commands:\n    - exec: a command\n  name: test-job\n  project: project\n  uuid: abcde\n",
        'yaml',
        kind_of(Hash)
      ) { response }
      chef_run # evaluate chef_run
    end
  end

  context 'job exists and is correct' do
    it 'does not modify the job' do
      client = double('rundeck-client')
      job = { 'uuid' => 'abcde', 'description' => '', 'loglevel' => 'INFO', 'sequence' => { 'commands' => [{ 'exec' => 'a command' }] }, 'name' => 'test-job', 'project' => 'project' }
      yaml = [job].to_yaml
      expect(Rundeck::Client).to receive(:new).and_return(client)
      expect(client).to receive(:export_jobs).with('project', 'yaml', kind_of(Hash)) { yaml }
      expect(client).not_to receive(:import_jobs)
      chef_run # evaluate chef_run
    end
  end
end
