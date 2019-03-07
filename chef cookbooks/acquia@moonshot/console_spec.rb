describe Moonshot::Commands::Console do
  describe '#execute' do
    it 'should start a pry session' do
      expect_any_instance_of(Moonshot::ControllerConfig).to receive(:update_for_account!)
      expect(Aws::EC2::Client).to receive(:new)
      expect(Aws::IAM::Client).to receive(:new)
      expect(Aws::AutoScaling::Client).to receive(:new)
      expect(Aws::CloudFormation::Client).to receive(:new)
      expect(Pry).to receive(:start)
      subject.execute
    end
  end
end
