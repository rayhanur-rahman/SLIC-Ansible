require "spec_helper"
require "json"

describe "chef-marketplace-ctl upgrade" do
  let(:marketplace_ctl) { OmnibusCtlTest.new("upgrade") }
  let(:omnibus_ctl) { marketplace_ctl.plugin }
  let(:process_success) { double("Process::Status", success?: true, exitstatus: 0) }
  let(:role) { "aio" }
  let(:upgrade_json_file) { "/opt/chef-marketplace/embedded/cookbooks/upgrade.json" }
  let(:upgrade_json_config) do
    {
      "chef-marketplace" => {
        "role" => role,
        "upgrade_packages" => required_packages
      },
      "run_list" => ["chef-marketplace::upgrade"]
    }
  end

  before do
    allow(omnibus_ctl).to receive(:run_chef).and_return(process_success)
    allow(File)
      .to receive(:exist?)
      .with("/etc/chef-marketplace/chef-marketplace-running.json")
      .and_return(false)
    allow(File)
      .to receive(:write)
      .with("/opt/chef-marketplace/embedded/cookbooks/upgrade.json")
      .and_return(true)
  end

  shared_examples "a proper upgrade" do
    it "writes the config json, converges the upgrade recipe, and exits properly" do
      expect(File)
        .to receive(:write)
        .with(upgrade_json_file, JSON.pretty_generate(upgrade_json_config))

      expect(omnibus_ctl)
        .to receive(:run_chef)
        .with(upgrade_json_file, "--lockfile /tmp/chef-client-upgrade.lock")

      expect { marketplace_ctl.execute(command) }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    end
  end

  context "when no arguments are given" do
    it "raises an error exits properly" do
      expect { marketplace_ctl.execute("upgrade") }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end
  end

  context "with --yes" do
    let(:command) { "upgrade --yes" }

    context "when a role is configured" do
      before do
        allow(File)
          .to receive(:exist?)
          .with("/etc/chef-marketplace/chef-marketplace-running.json")
          .and_return(true)
        allow(IO)
          .to receive(:read)
          .with("/etc/chef-marketplace/chef-marketplace-running.json")
          .and_return(json)
      end

      let(:json) { { "chef-marketplace" => { "role" => role } }.to_json }

      context "when the role is analytics" do
        let(:role) { "analytics" }
        let(:required_packages) { %w{chef-marketplace analytics} }

        it_behaves_like "a proper upgrade"
      end

      context "when the role is a chef server" do
        let(:role) { "server" }
        let(:required_packages) { %w{chef-marketplace chef-server-aio} }

        it_behaves_like "a proper upgrade"
      end

      context "when the role is an All-In-One" do
        let(:role) { "aio" }
        let(:required_packages) { %w{chef-marketplace chef-server-aio analytics} }

        it_behaves_like "a proper upgrade"
      end

      context "when the role is compliance" do
        let(:role) { "compliance" }
        let(:required_packages) { %w{chef-marketplace compliance} }

        it_behaves_like "a proper upgrade"
      end

      context "when the role is automate" do
        let(:role) { "automate" }
        let(:required_packages) { %w{chef-marketplace automate chef-server} }

        it_behaves_like "a proper upgrade"
      end
    end

    context "when there is no role configured" do
      let(:required_packages) { %w{chef-marketplace chef-server-aio analytics} }

      it_behaves_like "a proper upgrade"
    end
  end

  context "with -s" do
    let(:command) { "upgrade -s" }
    let(:required_packages) { %w{chef-server-aio} }

    it_behaves_like "a proper upgrade"
  end

  context "with -m" do
    let(:command) { "upgrade -m" }
    let(:required_packages) { %w{chef-marketplace} }

    it_behaves_like "a proper upgrade"
  end

  context "with -a" do
    let(:command) { "upgrade -a" }
    let(:required_packages) { %w{analytics} }

    it_behaves_like "a proper upgrade"
  end

  context "with -c" do
    let(:command) { "upgrade -c" }
    let(:required_packages) { %w{compliance} }

    it_behaves_like "a proper upgrade"
  end

  context "with -d" do
    let(:command) { "upgrade -d" }
    let(:required_packages) { %w{automate} }

    it_behaves_like "a proper upgrade"
  end
end
