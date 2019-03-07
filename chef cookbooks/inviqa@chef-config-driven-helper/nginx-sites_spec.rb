describe 'config-driven-helper::nginx-sites' do
  let(:http_vhost) { '/etc/nginx/sites-available/example.com' }
  let(:https_vhost) { '/etc/nginx/sites-available/example.com.ssl' }

  context 'with proxy config' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['ssl_certs']['t.cert'] = 'an example cert'
        node.set['ssl_certs']['t.key'] = 'an example key'
        node.set['nginx']['sites']['example.com']['ssl']['certfile'] = 't.cert'
        node.set['nginx']['sites']['example.com']['ssl']['keyfile'] = 't.key'
        node.set['nginx']['sites']['example.com']['server_name'] = 'example.com'
        node.set['nginx']['sites']['example.com']['protocols'] = %w(http https)
        node.set['nginx']['sites']['example.com']['locations']['/'] = {
          'type' => 'path_not_regex',
          'mode' => 'reverse-proxy',
          'proxy' => {
            'location' => 'http://127.0.0.1:8080'
          },
          'server_params' => {
            'proxy_connect_timeout' => '30'
          }
        }
        node.set['nginx']['sites']['example.com']['locations']['/preserve_scheme'] = {
          'type' => 'path_not_regex',
          'mode' => 'reverse-proxy',
          'proxy' => {
            'location' => 'http://127.0.0.1:8080',
            'preserve_scheme' => true
          }
        }
      end.converge('recipe[nginx]', described_recipe)
    end

    it 'will write a proxy configuration' do
      [http_vhost, https_vhost].each do |vhost|
        expect(chef_run).to render_file(vhost).with_content(
          %r{location / \{[^\}]*proxy_pass http://127.0.0.1:8080;}m
        )
      end
    end

    it 'will write a https forwarded proto header for the ssl vhost' do
      [http_vhost, https_vhost].each do |vhost|
        expect(chef_run).to render_file(vhost).with_content(
          %r{location / \{[^\}]*proxy_set_header X-Forwarded-Proto \$scheme;}m
        )
      end
    end

    it 'will write a proxy_connect_timeout configuration' do
      [http_vhost, https_vhost].each do |vhost|
        expect(chef_run).to render_file(vhost).with_content(
          %r{location / \{[^\}]*proxy_connect_timeout 30;}m
        )
      end
    end

    it 'will preserve the protocol' do
      [http_vhost, https_vhost].each do |vhost|
        expect(chef_run).to render_file(vhost).with_content(
          %r{location /preserve_scheme \{[^\}]*proxy_pass \$scheme://127.0.0.1:8080;}m
        )
      end
    end

    it 'will write ssl cert to correct file' do
      expect(chef_run).to render_file("t.cert").with_content(
        "an example cert"
      )
      expect(chef_run).to render_file("t.key").with_content(
        "an example key"
      )
    end
  end

  context 'with an existing ssl file but no new content' do
    cached(:chef_run) do
      allow(File).to receive(:'empty?').with('t.cert').and_return(true)
      allow(File).to receive(:'empty?').with('t.key').and_return(true)
      ChefSpec::SoloRunner.new do |node|
        node.set['nginx']['sites']['example.com']['ssl']['certfile'] = 't.cert'
        node.set['nginx']['sites']['example.com']['ssl']['keyfile'] = 't.key'
        node.set['nginx']['sites']['example.com']['server_name'] = 'example.com'
        node.set['nginx']['sites']['example.com']['protocols'] = %w(https)
      end.converge('recipe[nginx]', described_recipe)
    end

    it 'will not write any content to ssl file' do
      expect(chef_run).not_to render_file("t.cert")
      expect(chef_run).not_to render_file("t.key")
    end
  end

  context 'without an existing ssl file and no new content' do
    cached(:chef_run) do
      allow(File).to receive(:'empty?').with('t.cert').and_return(false)
      allow(File).to receive(:'empty?').with('t.key').and_return(true)
      ChefSpec::SoloRunner.new do |node|
        node.set['nginx']['sites']['example.com']['ssl']['certfile'] = 't.cert'
        node.set['nginx']['sites']['example.com']['ssl']['keyfile'] = 't.key'
        node.set['nginx']['sites']['example.com']['server_name'] = 'example.com'
        node.set['nginx']['sites']['example.com']['protocols'] = %w(https)
      end.converge('recipe[nginx]', described_recipe)
    end

    it 'will warn that no ssl file exists' do
      expect{chef_run.resources.find { |r| r.name == 'raise if issue with t.cert' }.old_run_action(:create)}.to raise_error
    end
  end
end
