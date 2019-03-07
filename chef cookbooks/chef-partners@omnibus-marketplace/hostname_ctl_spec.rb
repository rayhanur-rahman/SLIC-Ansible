require "spec_helper"
require "marketplace/hostname"

describe "chef-marketplace-ctl hostname" do
  let(:marketplace_ctl) { OmnibusCtlTest.new("hostname") }
  let(:omnibus_ctl) { marketplace_ctl.plugin }
  let(:process_success) { double("Process::Status", success?: true, exitstatus: 0) }
  let(:current_hostname) { "current.hostname.com" }
  let(:json_file) { "/opt/chef-marketplace/embedded/cookbooks/update-hostname.json" }
  let(:hostname) do
    double("Marketplace::Hostname",
           associate_eip: true,
           write_chef_json: true,
           resolve: current_hostname)
  end
  let(:server_configured) { false }
  let(:manage_configured) { false }
  let(:analytics_configured) { false }

  before do
    allow(omnibus_ctl).to receive(:run_chef).and_return(process_success)
    allow(omnibus_ctl).to receive(:run_command).and_return(process_success)
    allow(Marketplace::Hostname).to receive(:new).and_return(hostname)
    allow(omnibus_ctl).to receive(:server_configured?).and_return(server_configured)
    allow(omnibus_ctl).to receive(:manage_configured?).and_return(manage_configured)
    allow(omnibus_ctl).to receive(:analytics_configured?).and_return(analytics_configured)
  end

  context "when no arguments are given" do
    context "when the hostname is resolvable" do
      it "outputs the hostname" do
        expect($stdout).to receive(:puts).with(current_hostname)
        expect { marketplace_ctl.execute("hostname") }
          .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
      end

      it "resolves the hostname" do
        expect(hostname).to receive(:resolve)
        expect { marketplace_ctl.execute("hostname") }
          .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
      end
    end

    context "when the hostname is not resolvable" do
      let(:current_hostname) { nil }

      it "raises an error" do
        expect { marketplace_ctl.execute("hostname") }
          .to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
      end
    end
  end

  context "when the input is -e with a hostname" do
    it "associates the eip" do
      expect(hostname).to receive(:associate_eip).with("fancy.hostname.com")
      expect { marketplace_ctl.execute("hostname -e fancy.hostname.com") }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    end

    it "sets the hostname" do
      expect(hostname)
        .to receive(:write_chef_json)
        .with(json_file, "fancy.hostname.com")
      expect(omnibus_ctl).to receive(:run_chef).with(json_file)
      expect { marketplace_ctl.execute("hostname -e fancy.hostname.com") }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    end
  end

  context "when the input is -e without a hostname" do
    it "raises an error" do
      expect { marketplace_ctl.execute("hostname -e") }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end
  end

  context "when the input is a new hostname" do
    it "sets the hostname" do
      expect(hostname)
        .to receive(:write_chef_json)
        .with(json_file, "fancy.hostname.com")
      expect(omnibus_ctl).to receive(:run_chef).with(json_file)
      expect { marketplace_ctl.execute("hostname fancy.hostname.com") }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    end
  end

  context "chef software packages are configured" do
    context "when only the chef server is configured" do
      let(:server_configured) { true }

      it "reconfigures chef server, reporting and marketplace" do
        expect(omnibus_ctl).to receive(:run_command).with("chef-server-ctl reconfigure")
        expect(omnibus_ctl).to receive(:run_command).with("opscode-reporting-ctl reconfigure")
        expect(omnibus_ctl).to receive(:run_command).with("chef-marketplace-ctl reconfigure")
        expect(omnibus_ctl).to_not receive(:run_command).with("opscode-analytics-ctl reconfigure")
        expect(omnibus_ctl).to_not receive(:run_command).with("opscode-manage-ctl reconfigure")

        expect { marketplace_ctl.execute("hostname fancy.hostname.com") }
          .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
      end
    end

    context "when only chef analytics is configured" do
      let(:analytics_configured) { true }

      it "reconfigures chef analytics and marketplace" do
        expect(omnibus_ctl).to receive(:run_command).with("chef-marketplace-ctl reconfigure")
        expect(omnibus_ctl).to receive(:run_command).with("opscode-analytics-ctl reconfigure")
        expect(omnibus_ctl).to_not receive(:run_command).with("chef-server-ctl reconfigure")
        expect(omnibus_ctl).to_not receive(:run_command).with("opscode-reporting-ctl reconfigure")
        expect(omnibus_ctl).to_not receive(:run_command).with("opscode-manage-ctl reconfigure")

        expect { marketplace_ctl.execute("hostname fancy.hostname.com") }
          .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
      end
    end

    context "when only manage is configure" do
      let(:manage_configured) { true }

      it "reconfigures only chef manage and marketplace" do
        expect(omnibus_ctl).to receive(:run_command).with("chef-marketplace-ctl reconfigure")
        expect(omnibus_ctl).to receive(:run_command).with("opscode-manage-ctl reconfigure")
        expect(omnibus_ctl).to_not receive(:run_command).with("opscode-analytics-ctl reconfigure")
        expect(omnibus_ctl).to_not receive(:run_command).with("chef-server-ctl reconfigure")
        expect(omnibus_ctl).to_not receive(:run_command).with("opscode-reporting-ctl reconfigure")

        expect { marketplace_ctl.execute("hostname fancy.hostname.com") }
          .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
      end
    end

    context "when all the packages are configured" do
      let(:server_configured) { true }
      let(:manage_configured) { true }
      let(:analytics_configured) { true }

      it "reconfigures all the packages" do
        expect(omnibus_ctl).to receive(:run_command).with("chef-marketplace-ctl reconfigure")
        expect(omnibus_ctl).to receive(:run_command).with("opscode-manage-ctl reconfigure")
        expect(omnibus_ctl).to receive(:run_command).with("opscode-analytics-ctl reconfigure")
        expect(omnibus_ctl).to receive(:run_command).with("chef-server-ctl reconfigure")
        expect(omnibus_ctl).to receive(:run_command).with("opscode-reporting-ctl reconfigure")

        expect { marketplace_ctl.execute("hostname fancy.hostname.com") }
          .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
      end
    end
  end

  context "no chef software packages are configured" do
    it "only reconfigures marketplace" do
      expect(omnibus_ctl).to receive(:run_command).with("chef-marketplace-ctl reconfigure")
      expect(omnibus_ctl).to_not receive(:run_command).with("opscode-manage-ctl reconfigure")
      expect(omnibus_ctl).to_not receive(:run_command).with("opscode-analytics-ctl reconfigure")
      expect(omnibus_ctl).to_not receive(:run_command).with("chef-server-ctl reconfigure")
      expect(omnibus_ctl).to_not receive(:run_command).with("opscode-reporting-ctl reconfigure")

      expect { marketplace_ctl.execute("hostname fancy.hostname.com") }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    end
  end
end
