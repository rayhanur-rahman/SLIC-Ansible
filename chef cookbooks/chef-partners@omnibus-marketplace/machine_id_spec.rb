require "spec_helper"
require "marketplace/reckoner"

class MachineIDTester
  include Marketplace::Reckoner::MachineID
end

describe Marketplace::Reckoner::MachineID do
  let(:tester) { MachineIDTester.new }

  describe '#machine_uuid' do
    it "returns the machine UUID" do
      expect(tester).to receive(:machine_id_contents).and_return("machine_uuid" => "test_uuid")
      expect(tester.machine_uuid).to eq("test_uuid")
    end
  end

  describe '#machine_salt' do
    it "returns the machine salt" do
      expect(tester).to receive(:machine_id_contents).and_return("machine_salt" => "test_salt")
      expect(tester.machine_salt).to eq("test_salt")
    end
  end

  describe '#machine_id_contents' do
    context "when the machine_id file exists" do
      it "returns a hash of the machine ID file" do
        expect(tester).to receive(:machine_id_file).twice.and_return("id_file")
        expect(File).to receive(:exist?).with("id_file").and_return(true)
        expect(File).to receive(:read).with("id_file").and_return('{"key1": "value1"}')

        machine_id_contents = tester.machine_id_contents
        expect(machine_id_contents["key1"]).to eq("value1")
      end
    end

    context "when the machine_id file does not exist" do
      it "generates a new one and returns the contents" do
        expect(tester).to receive(:machine_id_file).and_return("id_file")
        expect(File).to receive(:exist?).with("id_file").and_return(false)
        expect(tester).to receive(:generate_machine_id).and_return("key2" => "value2")

        machine_id_contents = tester.machine_id_contents
        expect(machine_id_contents["key2"]).to eq("value2")
      end
    end
  end

  describe "generate_machine_id" do
    it "writes out a new machine ID file and returns a hash of contents" do
      expect(SecureRandom).to receive(:uuid).twice.and_return("uuid1", "uuid2")
      expect(tester).to receive(:machine_id_file).and_return("id_file")
      expect(File).to receive(:write).with("id_file", '{"machine_uuid":"uuid1","machine_salt":"uuid2"}')

      machine_id_contents = tester.generate_machine_id
      expect(machine_id_contents["machine_uuid"]).to eq("uuid1")
      expect(machine_id_contents["machine_salt"]).to eq("uuid2")
    end
  end
end
