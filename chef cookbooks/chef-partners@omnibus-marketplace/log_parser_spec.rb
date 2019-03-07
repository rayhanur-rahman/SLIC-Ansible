require "spec_helper"
require "marketplace/reckoner"

describe Marketplace::Reckoner::Metrics::LogParser do
  it_behaves_like "a standard metric collector"

  let(:parser) { described_class.allocate }

  describe '#filenames' do
    it "raises an exception" do
      expect { described_class.allocate.send(:filenames) }.to raise_error(RuntimeError)
    end
  end

  describe '#metric_matchers' do
    it "raises an exception" do
      expect { described_class.allocate.send(:metric_matchers) }.to raise_error(RuntimeError)
    end
  end

  describe '#file_markers' do
    before do
      allow(parser).to receive(:marker_file).and_return("marker_file")
    end

    context "when the file does not exist" do
      it "returns an empty hash" do
        expect(File).to receive(:exist?).with("marker_file").and_return(false)
        expect(parser.file_markers).to eq({})
      end
    end

    context "when the file exists" do
      it "returns a hash of the parsed JSON from the file" do
        expect(File).to receive(:exist?).with("marker_file").and_return(true)
        expect(File).to receive(:read).with("marker_file")
          .and_return('{"key1":"value1","key2":"value2"}')

        file_markers = parser.file_markers
        expect(file_markers["key1"]).to eq("value1")
        expect(file_markers["key2"]).to eq("value2")
      end
    end
  end

  describe '#marker_for' do
    before do
      allow(parser).to receive(:parser_class).and_return("FakeClass")
      allow(parser).to receive(:file_markers).and_return(markers)
    end

    context "when the parser class is not in the markers" do
      let(:markers) { { "AnotherClass" => {} } }

      it "returns an empty hash" do
        expect(parser.marker_for("filename")).to eq({})
      end
    end

    context "when the parser class is in the markers" do
      let(:markers) { { "FakeClass" => { "filename" => 1234 } } }

      it "returns the contents of the makers for that class and filename" do
        expect(parser.marker_for("filename")).to eq(1234)
      end
    end
  end

  describe '#seek_for' do
    before do
      allow(parser).to receive(:marker_for).with("filename").and_return(marker)
    end

    context "when the seek is nil" do
      let(:marker) { {} }
      it "returns 0" do
        expect(parser.seek_for("filename")).to eq(0)
      end
    end

    context "when the seek is not nil" do
      let(:marker) { { "seek" => 50 } }
      it "returns the seek" do
        expect(parser.seek_for("filename")).to eq(50)
      end
    end
  end

  describe '#last_parse_time_for' do
    before do
      allow(parser).to receive(:marker_for).with("filename").and_return(marker)
    end

    context "when the time is nil" do
      let(:marker) { {} }
      it "returns an epoch time object" do
        expect(parser.last_parse_time_for("filename")).to eq(Time.at(0))
      end
    end

    context "when the time is not nil" do
      let(:marker) { { "last_parse_time" => 341_452_800 } }
      it "returns the seek" do
        expect(parser.last_parse_time_for("filename")).to eq(Time.at(341_452_800))
      end
    end
  end

  describe '#update_marker_for' do
    let(:time_now)    { double("time_now") }
    let(:marker_json) { double("marker_json") }
    let(:marker_hash) do
      {
        "FakeClass" => {
          "fakefile.txt" => {
            "seek" => 123,
            "last_parse_time" => 321
          }
        }
      }
    end

    it "writes out an update marker file" do
      allow(parser).to receive(:parser_class).and_return("FakeClass")
      expect(parser).to receive(:marker_file).and_return("marker_file")
      expect(parser).to receive(:file_markers).and_return({})
      expect(Time).to receive(:now).and_return(time_now)
      expect(time_now).to receive(:to_i).and_return(321)
      expect(JSON).to receive(:pretty_generate).with(marker_hash).and_return(marker_json)
      expect(File).to receive(:write).with("marker_file", marker_json)

      parser.update_marker_for("fakefile.txt", 123)
    end
  end

  describe '#files_to_parse' do
    it "returns a sorted list of correct files" do
      expect(parser).to receive(:last_parse_time_for).with("file_pattern").and_return(50)
      expect(Dir).to receive(:glob).with("file_pattern").and_return(%w{file1 file2 file3 file4})
      expect(File).to receive(:mtime).at_least(:once).with("file1").and_return(100)
      expect(File).to receive(:mtime).at_least(:once).with("file2").and_return(25)
      expect(File).to receive(:mtime).at_least(:once).with("file3").and_return(300)
      expect(File).to receive(:mtime).at_least(:once).with("file4").and_return(200)

      expect(parser.files_to_parse("file_pattern")).to eq(%w{file3 file4 file1})
    end
  end

  describe '#parse_file' do
    let(:file) { double("file") }

    context "when the file does not exist" do
      it "does not attempt to open the file" do
        expect(File).to receive(:exist?).with("file1").and_return(false)
        expect(File).not_to receive(:open).with("file1", "r")
        parser.parse_file("file1", 0)
      end
    end

    context "when the file exists" do
      before do
        allow(parser).to receive(:filenames)
        expect(File).to receive(:exist?).with("file1").and_return(true)
        allow(File).to receive(:size).with("file1")
        allow(file).to receive(:size).and_return(100)
        allow(file).to receive(:seek)
        expect(File).to receive(:open).with("file1", "r").and_yield(file)
        expect(file).to receive(:eof?).exactly(4).times.and_return(false, false, false, true)
        expect(file).to receive(:readline).exactly(3).times.and_return(
          "blah blah metric1 blah\n",
          "here's something for metric2",
          "another line for metric1\n"
        )
        expect(parser).to receive(:metric_matchers).at_least(:once).and_return(
          metric1: proc { |line| line.include?("metric1") },
          metric2: proc { |line| line.include?("metric2") }
        )
      end

      context "when the seek marker is bigger than the filesize" do
        it "does not attempt to seek in the file" do
          expect(file).to receive(:size).and_return(50)
          expect(file).not_to receive(:seek).with(100)

          parser.send(:initialize)
          parser.parse_file("file1", 100)
        end
      end

      context "when the seek marker is not bigger than the filesize" do
        it "seeks in the file" do
          expect(file).to receive(:size).and_return(500)
          expect(file).to receive(:seek).with(100)

          parser.send(:initialize)
          parser.parse_file("file1", 100)
        end
      end

      it "counted the metrics correctly" do
        parser.send(:initialize)
        parser.parse_file("file1", 0)
        expect(parser.counts[:metric1]).to eq(2)
        expect(parser.counts[:metric2]).to eq(1)
      end

      it "returns the size of the file so markers can be updated" do
        expect(File).to receive(:size).with("file1").and_return(1234)
        parser.send(:initialize)
        expect(parser.parse_file("file1", 0)).to eq(1234)
      end
    end
  end
end
