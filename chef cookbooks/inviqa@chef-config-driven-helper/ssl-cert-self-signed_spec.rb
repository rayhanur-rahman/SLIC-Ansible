describe 'config-driven-helper::ssl-cert-self-signed' do
  context 'with a split nginx site configuration' do
    cached(:chef_run) do
      solo = ChefSpec::SoloRunner.new do |node|
        node.set['nginx']['sites']['mysite1'] = {
          server_name: 'mysite1.dev',
          protocols: ['http', 'https'],
          ssl: {
            certfile: "/etc/ssl/certs/cert-mysite1.pem",
            keyfile: "/etc/ssl/private/key-mysite1.pem",
            subject: {
              country: "GB",
              locality: "Manchester",
              organisation: "Inviqa",
              organisational_unit: "",
            }
          }
        }
        node.set['nginx']['sites']['mysite2'] = {
          server_name: 'mysite2.dev',
          server_aliases: ['js.mysite2.dev', 'css.mysite2.dev'],
          protocols: ['http', 'https'],
          ssl: {
            certfile: "/etc/ssl/certs/cert-mysite2.pem",
            keyfile: "/etc/ssl/private/key-mysite2.pem",
            subject: {
              country: "GB",
              locality: "Manchester",
              organisation: "Inviqa",
              organisational_unit: "",
            }
          }
        }
        node.set['nginx']['sites']['mysite3'] = {
          server_name: 'mysite3.dev',
          protocols: ['http', 'https'],
          ssl: {
            certfile: "/etc/ssl/certs/cert-mysite1.pem",
            keyfile: "/etc/ssl/private/key-mysite1.pem",
            subject: {
              country: "GB",
              locality: "Manchester",
              organisation: "Inviqa",
              organisational_unit: "",
            }
          }
        }
        node.set['certbot']['cert-owner']['email'] = 'root@localhost'
      end

      solo.converge(described_recipe) do
        solo.resource_collection.insert(Chef::Resource::Service.new('nginx', solo.run_context))
      end
    end

    it "will create a separate certificate per site when use_sni is on" do
      expect(chef_run).to run_execute('Create SSL Certificate for /etc/ssl/certs/cert-mysite1.pem').with({
        command: 'openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /etc/ssl/private/key-mysite1.pem -out /etc/ssl/certs/cert-mysite1.pem -subj "/C=GB/L=Manchester/O=Inviqa/CN=mysite1.dev"'
      })
      expect(chef_run).to run_execute('Create SSL Certificate for /etc/ssl/certs/cert-mysite2.pem').with({
        command: 'openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /etc/ssl/private/key-mysite2.pem -out /etc/ssl/certs/cert-mysite2.pem -subj "/C=GB/L=Manchester/O=Inviqa/CN=mysite2.dev"'
      })
    end

    it "will restart the web server" do
      resource = chef_run.execute('Create SSL Certificate for /etc/ssl/certs/cert-mysite1.pem')
      expect(resource).to notify('service[nginx]').to(:reload).delayed
      resource = chef_run.execute('Create SSL Certificate for /etc/ssl/certs/cert-mysite2.pem')
      expect(resource).to notify('service[nginx]').to(:reload).delayed
    end
  end
end
