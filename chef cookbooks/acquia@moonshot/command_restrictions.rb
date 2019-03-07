class RestrictedCommand1 < Moonshot::Command
  self.only_in_account = 'jeff'

  def execute
    puts "Yep, I ran!"
  end
end

class RestrictedCommand2 < Moonshot::Command
  self.only_in_account = [ 'jeff', 'panda' ]

  def execute
    puts "Yep, I ran!"
  end
end

class UnrestrictedCommand < Moonshot::Command
  def execute
    puts "Yep, I ran!"
  end
end

describe 'command account restrictions' do
  def try(klass)
    Moonshot::CommandLineDispatcher.new('stuff', klass, [])
      .dispatch!
  end
  
  before(:each) do
    Moonshot::AccountContext.set(account_name)
    ARGV.clear
  end

  context 'in the "jeff" account' do
    let(:account_name) { 'jeff' }

    it 'should let us run RestrictedCommand1' do
      expect { try(RestrictedCommand1) }
        .to output(/Yep, I ran!/).to_stdout
    end
    
    it 'should let us run RestrictedCommand2' do
      expect { try(RestrictedCommand2) }
        .to output(/Yep, I ran!/).to_stdout
    end
      
    it 'should let us run UnrestrictedCommand' do
      expect { try(UnrestrictedCommand) }
        .to output(/Yep, I ran!/).to_stdout
    end
  end

  context 'in the "panda" account' do
    let(:account_name) { 'panda' }

    it 'should not let us run RestrictedCommand1' do
      expect { try(RestrictedCommand1) }
        .to raise_error(/Command account restriction/)
        .and output(/can only be run/).to_stderr
    end

    it 'should let us run RestrictedCommand2' do
      expect { try(RestrictedCommand2) }
        .to output(/Yep, I ran!/).to_stdout
    end

    it 'should let us run UnrestrictedCommand' do
      expect { try(UnrestrictedCommand) }
        .to output(/Yep, I ran!/).to_stdout
    end
  end

  context 'in the "carrot" account' do
    let(:account_name) { 'carrot' }

    it 'should not let us run RestrictedCommand1' do
      expect { try(RestrictedCommand1) }
        .to raise_error(/Command account restriction/)
        .and output(/can only be run/).to_stderr
    end

    it 'should not let us run RestrictedCommand2' do
      expect { try(RestrictedCommand2) }
        .to raise_error(/Command account restriction/)
        .and output(/can only be run/).to_stderr
    end

    it 'should let us run UnrestrictedCommand' do
      expect { try(UnrestrictedCommand) }
        .to output(/Yep, I ran!/).to_stdout
    end
  end
end
