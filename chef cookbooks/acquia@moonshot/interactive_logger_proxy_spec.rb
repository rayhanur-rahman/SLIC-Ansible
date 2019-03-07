shared_examples 'compatible class' do |expected_class|
  expected_class.public_instance_methods(false).each do |name|
    describe "##{name}" do
      it 'should be defined.' do
        described_class.public_instance_method(name)
      end

      it "should have method arguments compatible with #{expected_class.name}##{name}" do
        expected_method = expected_class.instance_method(name)
        actual_method = described_class.instance_method(name)
        expect(actual_method.arity).to eq(-1).or be >= expected_method.arity
        actual_method.parameters.each_with_index do |(type, arg), index|
          # If it's a required argument, expect it to be identical.
          if type == :req
            expect(name => expected_method.parameters[index])
              .to eq(name => [type, arg])
          end
        end
      end
    end
  end
end

describe Moonshot::InteractiveLoggerProxy do
  include_examples 'compatible class', InteractiveLogger
end

describe Moonshot::InteractiveLoggerProxy::Step do
  include_examples 'compatible class', InteractiveLogger::Step
end
