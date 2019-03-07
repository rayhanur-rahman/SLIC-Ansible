if Gem::Dependency.new('chef', '>= 12.9').match?('chef', Chef::VERSION)
  raise 'config-driven-helper::packages not supported in chef >= 12.9. Please use config-driven-helper::packages-additional instead, which uses a different syntax'
end

if node['packages']
  node['packages'].each do |name|
    package name do
      action :install
    end
  end
end
