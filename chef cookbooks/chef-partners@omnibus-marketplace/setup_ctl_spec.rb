require "spec_helper"
require "ostruct"

describe "chef-marketplace-ctl setup" do
  let(:marketplace_ctl) do
    @ctl = OmnibusCtlTest.new("setup")
    # Omnibus::Ctl will Kernel#eval the Marketplace source so we have to stub
    # after we create the object
    allow(Marketplace).to receive(:setup).and_return(true)
    @ctl
  end
  let(:omnibus_ctl) { marketplace_ctl.plugin }

  before do
    allow(omnibus_ctl)
      .to receive_message_chain(:run_command, :exitstatus).and_return(0)
  end

  context "when the hostname is not resolvable" do
    before do
      allow(omnibus_ctl)
        .to receive_message_chain(:run_command, :exitstatus).and_return(1)
    end

    it "raises an error" do
      expect { marketplace_ctl.execute("setup") }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end
  end

  context "when the hostname is resolvable" do
    it "does not raise an error" do
      expect { marketplace_ctl.execute("setup") }.to_not raise_error
    end
  end

  shared_examples_for "chef-marketplace-ctl cli arguments" do
    it "should properly parse the value from ARGV and add it to the options" do
      # mock options
      opts = OpenStruct.new
      opts[option_name] = option_value

      expect(Marketplace).to receive(:setup) do |o, omnibus_ctl|
        expect(o.send(option_name)).to eq(option_value)
      end
      expect(Kernel).to_not receive(:eval)

      marketplace_ctl.execute("setup #{input}")
    end
  end

  [
    [ "--eula", "agree_to_eula", true ],
    [ "--register", "register_node", true ],
    [ "--preconfigure", "preconfigure", true ],
    [ "--license-url http://example.org/delivery.license", "license_url", "http://example.org/delivery.license" ],
    [ "--license-base64 ZGVsaXZlcnktbGl==", "license_base64", "ZGVsaXZlcnktbGl==" ],
    [ "-u julia", "username", "julia" ],
    [ "-p drowssap", "password", "drowssap" ],
    [ "-f julia", "first_name", "julia" ],
    [ "-l child", "last_name", "child" ],
    [ "-e julia@child.com", "email", "julia@child.com" ],
    [ "-o marvelous", "organization", "marvelous" ],
  ].each do |params|
    context "when the input is #{params[0]}" do
      it_behaves_like "chef-marketplace-ctl cli arguments" do
        let(:input) { params[0] }
        let(:option_name) { params[1] }
        let(:option_value) { params[2] }
      end
    end
  end
end
