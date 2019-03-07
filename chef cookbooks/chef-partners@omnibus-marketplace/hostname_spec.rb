require "spec_helper"
require "marketplace/hostname"
require "json"

describe Marketplace::Hostname do
  subject { described_class.new }

  let(:ohai) { double("Ohai::System") }
  let(:current_hostname) { "current.hostname.com" }

  before do
    allow(Ohai::System).to receive(:new).and_return(ohai)
    allow(ohai).to receive(:all_plugins).and_return({ "fqdn" => current_hostname })
  end

  describe '#resolve' do
    context "when the fqdn is resolvable" do
      it "returns the fqdn" do
        expect(subject.resolve).to eq(current_hostname)
      end
    end
  end

  describe '#associate_eip' do
    context "when credentials are present" do
      context "when the credentials lack permissions" do
        it "raises an error" do
          skip "not implemented yet"
        end
      end

      context "when the credentials have permissions" do
        it "associates the eip" do
          skip "not implemented yet"
        end
      end
    end
  end

  describe '#write_chef_json' do
    let(:json_file) { "/opt/chef-marketplace/embedded/cookbooks/update-hostname.json" }
    let(:json) do
      JSON.parse(
        '{"set_fqdn": "test.domain.com","run_list": ["recipe[hostname::default]"]}'
      )
    end

    it "writes a chef-client json file" do
      allow(File).to receive(:write).and_return(true)
      expect(File).to receive(:write).with(json_file, JSON.pretty_generate(json))
      subject.write_chef_json(json_file, "test.domain.com")
    end
  end
end
