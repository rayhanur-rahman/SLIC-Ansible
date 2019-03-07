require "spec_helper"
require "ostruct"
require "marketplace/setup"

describe Marketplace::Setup do
  subject { described_class.new(options, omnibus_ctl) }

  let(:options) { OpenStruct.new }
  let(:omnibus_ctl) { double("OmnibusCtl") }
  let(:current_hostname) { "current.hostname.com" }
  let(:json) { { "chef-marketplace" => { "role" => "tofu" } }.to_json }
  let(:secrets) do
    {
      "biscotti" => { "token" => "biscotti-token" },
      "automate" => {
        "postgresql" => { "superuser_password" => "db-pass" },
        "data_collector" => { "token" => "dc-token" },
        "passwords" => {
          "chef_user" => "chef_user_pass",
          "admin_user" => "admin_user_pass",
          "builder_user" => "builder_user_pass",
        },
      },
    }.to_json
  end

  before do
    allow(File).to receive(:exist?).and_call_original
    allow(IO).to receive(:read).and_call_original

    # Stub out the role
    allow(File)
      .to receive(:exist?)
      .with("/etc/chef-marketplace/chef-marketplace-running.json")
      .and_return(true)
    allow(IO)
      .to receive(:read)
      .with("/etc/chef-marketplace/chef-marketplace-running.json")
      .and_return(json)

    # Stub the secrets
    allow(File)
      .to receive(:exist?)
      .with("/etc/chef-marketplace/chef-marketplace-secrets.json")
      .and_return(true)
    allow(IO)
      .to receive(:read)
      .with("/etc/chef-marketplace/chef-marketplace-secrets.json")
      .and_return(secrets)

    allow(options).to receive(:preconfigure).and_return(false)
  end

  describe "#setup" do
    before do
      allow(subject).to receive(:role).and_return(role)
      allow(subject).to receive(:redirect_user).and_return(true)
      allow(subject).to receive(:reconfigure).and_return(true)
      allow(subject).to receive(:update_software).and_return(true)
      allow(subject).to receive(:validate_options).and_return(true)
      allow(subject).to receive(:agree_to_eula).and_return(true)
      allow(subject).to receive(:validate_payment).and_return(true)
      allow(subject).to receive(:create_server_user).and_return(true)
      allow(subject).to receive(:create_server_org).and_return(true)
      allow(subject).to receive(:create_compliance_user).and_return(true)
      allow(subject).to receive(:register_node).and_return(true)
      allow(subject).to receive(:ask_for_node_registration).and_return(true)
      allow(subject).to receive(:wait_for_cloud_init_preconfigure).and_return(true)
      allow(subject).to receive(:create_default_users).and_return(true)
      allow(subject).to receive(:setup_chef_server_pg_password).and_return(true)
      allow(subject).to receive(:retry_command).and_return(true)
      allow(subject).to receive(:setup_license).and_return(true)
    end

    context "when the server has not been preconfigured" do
      before { allow(subject).to receive(:preconfigured?).and_return(false) }

      context "when the role is server" do
        let(:role) { "server" }

        it "sets up the chef server" do
          expect(subject).to receive(:reconfigure).with(:server).once
          expect(subject).to receive(:reconfigure).with(:manage).once
          expect(subject).to receive(:reconfigure).with(:reporting).once
          expect(subject).to_not receive(:reconfigure).with(:compliance)
          expect(subject).to_not receive(:reconfigure).with(:analytics)

          subject.setup
        end
      end

      context "when the role is analytics" do
        let(:role) { "analytics" }

        it "sets up chef analytics" do
          expect(subject).to receive(:reconfigure).with(:analytics).once
          expect(subject).to_not receive(:reconfigure).with(:server)
          expect(subject).to_not receive(:reconfigure).with(:manage)
          expect(subject).to_not receive(:reconfigure).with(:reporting)
          expect(subject).to_not receive(:reconfigure).with(:compliance)

          subject.setup
        end
      end

      context "when the role is aio" do
        let(:role) { "aio" }

        it "sets up chef server and analytics" do
          expect(subject).to receive(:reconfigure).with(:server).once
          expect(subject).to receive(:reconfigure).with(:manage).once
          expect(subject).to receive(:reconfigure).with(:reporting).once
          expect(subject).to receive(:reconfigure).with(:analytics).once
          expect(subject).to_not receive(:reconfigure).with(:compliance)

          subject.setup
        end
      end
    end

    context "when the server has been preconfigured" do
      before { allow(subject).to receive(:preconfigured?).and_return(true) }

      context "when the role is server" do
        let(:role) { "server" }

        it "does not set up the chef server" do
          expect(subject).to_not receive(:reconfigure).with(:server)
          expect(subject).to_not receive(:reconfigure).with(:manage)
          expect(subject).to_not receive(:reconfigure).with(:reporting)
          expect(subject).to_not receive(:reconfigure).with(:compliance)
          expect(subject).to_not receive(:reconfigure).with(:analytics)

          subject.setup
        end
      end

      context "when the role is analytics" do
        let(:role) { "analytics" }

        it "does not set up chef analytics" do
          expect(subject).to_not receive(:reconfigure).with(:analytics)
          expect(subject).to_not receive(:reconfigure).with(:server)
          expect(subject).to_not receive(:reconfigure).with(:manage)
          expect(subject).to_not receive(:reconfigure).with(:reporting)
          expect(subject).to_not receive(:reconfigure).with(:compliance)

          subject.setup
        end
      end

      context "when the role is aio" do
        let(:role) { "aio" }

        it "does not set up chef server and analytics" do
          expect(subject).to_not receive(:reconfigure).with(:server)
          expect(subject).to_not receive(:reconfigure).with(:manage)
          expect(subject).to_not receive(:reconfigure).with(:reporting)
          expect(subject).to_not receive(:reconfigure).with(:analytics)
          expect(subject).to_not receive(:reconfigure).with(:compliance)

          subject.setup
        end
      end
    end

    context "when the preconfigure option is passed" do

      before { allow(options).to receive(:preconfigure).and_return(true) }

      context "when the role is aio" do
        let(:role) { "aio" }

        it "only preconfigures the software" do
          expect(subject).to receive(:configure_software).once
          expect(subject).to_not receive(:create_default_users)
          expect(subject).to_not receive(:update_software)
          expect(subject).to_not receive(:agree_to_eula)
          expect(subject).to_not receive(:redirect_user)

          subject.setup
        end
      end

      context "when the role is automate" do
        let(:role) { "automate" }

        it "sets up automate and chef server with biscotti not running" do
          # set up marketplace
          expect(subject).to receive(:reconfigure).with(:marketplace)

          # stop biscotti until automate and chef server are running
          expect(subject)
            .to receive(:retry_command)
            .with(
              "chef-marketplace-ctl stop biscotti",
              retries: 2)
            .once

          # setup the initial license
          expect(subject).to receive(:setup_license).once

          # set up automate
          expect(subject).to receive(:reconfigure).with(:delivery).once

          # make sure the chef server db password is set
          expect(subject).to receive(:setup_chef_server_pg_password).once

          # set up chef server
          expect(subject).to receive(:reconfigure).with(:server).once

          # make sure marketplace is running with the latest data
          expect(subject).to receive(:reconfigure).with(:marketplace)

          # set up automate users/orgs
          expect(subject).to receive(:setup_automate).once

          # restart biscotti
          expect(subject)
            .to receive(:retry_command)
            .with(
              "chef-marketplace-ctl start biscotti",
              retries: 2)
            .once

          subject.setup
        end
      end
    end
  end

  describe "#role" do
    context "when chef-marketplace has been configured" do
      it "loads the role from the running json" do
        expect(subject.send(:role)).to eq("tofu")
      end
    end

    context "when chef marketplace has not been configured" do
      before do
        allow(File)
          .to receive(:exist?)
          .with("/etc/chef-marketplace/chef-marketplace-running.json")
          .and_return(false)
      end

      it "raises a system exit" do
        expect { subject.send(:role) }
          .to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
      end
    end
  end

  describe "#setup_license" do
    let(:file) { Tempfile.new("license") }
    let(:url) { "http://aws.s3.mybucket/my/delivery.license" }
    let(:encoded_license) { "bGljZW5zZQ==\n" }
    let(:decoded_license) { "license" }
    let(:options) { OpenStruct.new(license_url: nil, license_base64: nil ) }

    before do
      allow(FileUtils)
        .to receive(:mkdir_p)
        .with("/var/opt/delivery/license")
        .and_return(true)

      allow(File).to receive(:open).and_call_original
      allow(File)
        .to receive(:open)
        .with("/var/opt/delivery/license/delivery.license", "w+")
        .and_yield(file)
    end

    after do
      FileUtils.rm(file)
    end

    it "ensures the license directory exists" do
      allow(FileUtils)
        .to receive(:mkdir_p)
        .with("/var/opt/delivery/license")
        .and_return(true)

      subject.send(:setup_license)
    end

    context "when the license url is given" do
      let(:options) do
        OpenStruct.new(license_url: url, license_base64: nil )
      end

      it "writes the license from the remote url" do
        allow(subject)
          .to receive(:open)
          .with(URI(url))
          .and_yield(StringIO.new(decoded_license))

        expect(subject).to receive(:open).with(URI(url))
        expect(file).to receive(:write).with(decoded_license)

        subject.send(:setup_license)
      end
    end

    context "when the base64 license is given" do
      let(:options) do
        OpenStruct.new(license_url: nil, license_base64: encoded_license )
      end

      it "decodes the license and writes the license file" do
        expect(file).to receive(:write).with(decoded_license)

        subject.send(:setup_license)
      end
    end
  end
end
