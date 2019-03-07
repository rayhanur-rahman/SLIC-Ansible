require "spec_helper"
require "ostruct"
require "securerandom"
require "marketplace/options"

def test_normalization_for(param)
  allow(subject).to receive(:required_options).and_return([param])
  expect(subject).to receive(:normalize_option).with(send(param))
  with_user_input(send(param)) { subject.validate }
end

describe Marketplace::Options do
  let(:first_name) { "John" }
  let(:last_name) { "O'Connell-Pants" }
  let(:username) { "John!" }
  let(:email) { "John@OCP.com" }
  let(:organization) { 'A full Organization-with-Special things!@#$%^*()' }
  let(:password) { "Ultra Secure Password!" }
  let(:options) { OpenStruct.new }

  subject { described_class.new(options) }

  describe '#validate' do
    it "asks and normalizes the first_name" do
      test_normalization_for("first_name")
    end

    it "asks and normalizes the last_name" do
      test_normalization_for("last_name")
    end

    it "asks and normalizes the username" do
      test_normalization_for("username")
    end

    it "asks and normalizes the organization" do
      test_normalization_for("organization")
    end

    it "retries if the organization name is too long" do
      long_org_name = SecureRandom.hex(256)
      valid_org_name = SecureRandom.hex(100)

      allow(subject).to receive(:required_options).and_return(["organization"])
      with_user_input do |stdin, stdout|
        stdin << "#{long_org_name}\n"
        stdin << "#{valid_org_name}\n"
        stdin << "#{valid_org_name}\n"
        stdin.rewind

        subject.validate
        stdout.rewind
        expect(stdout.readlines.to_s).to match(/must be between 1 and 255 characters/)
      end
    end

    it "asks and normalizes the email" do
      allow(subject).to receive(:required_options).and_return(["email"])
      expect(subject).to_not receive(:normalize_option).with(email)
      expect(subject).to receive(:normalize_email).with(email)

      with_user_input(email) { subject.validate }
    end

    it "retries if the email address is invalid" do
      allow(subject).to receive(:required_options).and_return(["email"])
      with_user_input do |stdin, stdout|
        stdin << "not-a-valid@email!.com\n"
        stdin << "valid@email.com\n"
        stdin << "valid@email.com\n"
        stdin.rewind

        subject.validate
        stdout.rewind
        expect(stdout.readlines.to_s).to match(/Your entry was not a valid email address/)
      end
    end

    it "asks and does not normalize the password" do
      allow(subject).to receive(:required_options).and_return(["password"])
      expect(subject).to_not receive(:normalize_option).with(password)

      with_user_input(password + "\n" + password) { subject.validate }
    end

    it "retries if the passwords do not match" do
      allow(subject).to receive(:required_options).and_return(["password"])
      with_user_input do |stdin, stdout|
        stdin << "password\n"
        stdin << "not_a_match\n"
        stdin << "password\n"
        stdin << "password\n"
        stdin.rewind

        subject.validate
        stdout.rewind
        expect(stdout.readlines.to_s).to match(/Your entries didn't match/)
      end
    end

    it "retries if the password is not long enough" do
      allow(subject).to receive(:required_options).and_return(["password"])
      with_user_input do |stdin, stdout|
        stdin << "short\n"
        stdin << "longenough\n"
        stdin << "longenough\n"
        stdin.rewind

        subject.validate
        stdout.rewind
        expect(stdout.readlines.to_s).to match(/Password must be at least 6 characters/)
      end
    end
  end

  describe '#normalize_option' do
    it "properly normalizes options" do
      expect(subject.normalize_option(first_name)).to eq("john")
      expect(subject.normalize_option(last_name)).to eq("oconnell_pants")
      expect(subject.normalize_option(username)).to eq("john")
      expect(subject.normalize_option(organization)).to eq("a_full_organization_with_special_things")
    end
  end

  describe '#normalize_email' do
    it "normalizes email addresses" do
      expect(subject.normalize_email(email)).to eq("john@ocp.com")
      expect(subject.normalize_email("email @ with spaces . com")).to eq("email@withspaces.com")
    end
  end

  describe '#required_options' do
    context "when the role is server" do
      before { subject.options.role = "server" }

      it "returns the correct options" do
        expect(subject.send(:required_options))
          .to eq(%w{first_name last_name username email organization password})
      end
    end

    context "when the role is analytics" do
      before { subject.options.role = "analytics" }

      it "returns the correct options" do
        expect(subject.send(:required_options)).to eq([])
      end
    end

    context "when the role is aio" do
      before { subject.options.role = "aio" }

      it "returns the correct options" do
        expect(subject.send(:required_options))
          .to eq(%w{first_name last_name username email organization password})
      end
    end
  end
end
