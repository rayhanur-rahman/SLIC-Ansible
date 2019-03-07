require 'fakefs/spec_helpers'

module Moonshot
  describe ArtifactRepository::S3BucketViaGithubReleases do
    let(:version) { '0.0.0'}
    let(:bucket_name) { 'moonshot-test-bucket' }
    let(:artifact_name) { "moonshot-#{version}-beta.tar.gz" }
    let(:hub_command) { "hub release download #{version}" }

    def fake_artifact
      FakeFS  { FileUtils.touch(artifact_name) }
    end

    def fake_checksum_file
      FakeFS do 
        base = File.basename(artifact_name, '.tar.gz')
        FileUtils.touch("#{base}.md5")
      end
    end

    subject { described_class.new(bucket_name) }

    describe '#download_from_github' do
      include FakeFS::SpecHelpers

      it 'should use hub to download the latest version' do
        obj = subject
        expect(obj).to receive(:sh_out) { fake_artifact }.with(hub_command)

        subject.send(:download_from_github, version)
      end

      it 'should raise RuntimeError when download has failed' do
        obj = subject
        expect(obj).to receive(:sh_out).at_least(:once)

        expect do
          obj.send(:download_from_github, version)
        end.to raise_error(RuntimeError)
      end

      it 'should retry if the download has failed' do
        obj = subject
        expect(obj).to receive(:sh_out).with(hub_command).exactly(3).times

        expect { obj.send(:download_from_github, version) }.to raise_error(RuntimeError)
      end

      it 'should verify the checksum of the downloaded artifact' do
        obj = subject

        expect(obj).to receive(:sh_out) do
          fake_artifact
          fake_checksum_file
        end.with(hub_command)
        
        expect(obj).to receive(:verify_download_checksum)
        obj.send(:download_from_github, version)
      end

      it 'should return the name of the downloaded artifact' do
        obj = subject

        allow(obj).to receive(:sh_out) { fake_artifact }.with(hub_command)
        
        expect(obj.send(:download_from_github, version))\
          .to eql("/#{artifact_name}")
      end
    end
  end
end
