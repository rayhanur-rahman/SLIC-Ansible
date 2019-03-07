describe 'config-driven-helper::iptables-standard' do
  context 'with default config' do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

    %w(
      http
      https
      ssh
    ).each do |rule|
      it "creates a rule for #{rule}" do
        expect(chef_run).to create_iptables_ng_rule("20-#{rule}").with(
          chain: 'STANDARD-FIREWALL',
          rule: "--protocol tcp --dport #{rule} --jump ACCEPT"
        )
      end
    end

    it "creates separate entries for ipv4 and ipv6 icmp allow" do
      expect(chef_run).to create_iptables_ng_rule("10-icmp-ipv4").with(
        chain: 'STANDARD-FIREWALL',
        rule: '--protocol icmp --jump ACCEPT',
        ip_version: 4
      )
      expect(chef_run).to create_iptables_ng_rule("10-icmp-ipv6").with(
        chain: 'STANDARD-FIREWALL',
        rule: '--protocol ipv6-icmp --jump ACCEPT',
        ip_version: 6
      )
    end
  end
  
  context 'with additonal config' do
    rules = {
      'rsync' => 'rsync',
      'non-standard-software' => '12345'
    }

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['iptables-standard']['allowed_incoming_ports'] = rules
      end.converge(described_recipe)
    end

    it "creates the additional mappings" do
      rules.each do |rule, port|
        expect(chef_run).to create_iptables_ng_rule("20-#{rule}").with(
          chain: 'STANDARD-FIREWALL',
          rule: "--protocol tcp --dport #{port} --jump ACCEPT"
        )
      end
    end

    it "still creates default rules" do
      %w(
        http
        https
        ssh
      ).each do |rule|
        expect(chef_run).to create_iptables_ng_rule("20-#{rule}").with(
          chain: 'STANDARD-FIREWALL',
          rule: "--protocol tcp --dport #{rule} --jump ACCEPT"
        )
      end
    end
  end

  context 'with remap config' do
    rules = {
      'http' => 8080,
      'https' => false
    }

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['iptables-standard']['allowed_incoming_ports'] = rules
      end.converge(described_recipe)
    end

    test_rules = {
      'http' => 8080,
      'ssh' => 'ssh'
    }

    it "creates the remapped and default rules" do
      test_rules.each do |rule, port|
        expect(chef_run).to create_iptables_ng_rule("20-#{rule}").with(
          chain: 'STANDARD-FIREWALL',
          rule: "--protocol tcp --dport #{port} --jump ACCEPT"
        )
      end
    end

    it "deletes unmapped rules" do
      expect(chef_run).to delete_iptables_ng_rule("20-https")
    end
  end
end