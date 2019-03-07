name "chef-marketplace-ctl"
license :project_license

dependency "omnibus-ctl"
dependency "bundler"
dependency "chef-marketplace-gem"
dependency "chef-marketplace-cookbooks"
dependency "runit"

source path: "#{project.files_path}/#{name}-commands"

build do
  erb source: "chef-marketplace-ctl.erb",
      dest: "#{install_dir}/bin/#{name}",
      mode: 0755,
      vars: {
        embedded_bin: "#{install_dir}/embedded/bin",
        embedded_service: "#{install_dir}/embedded/service"
      }

  sync project_dir, "#{install_dir}/embedded/service/chef-marketplace-ctl/"

  bundle "install --without development", env: with_standard_compiler_flags(with_embedded_path)

  copy "#{Omnibus::Config.project_root}/Rakefile", "#{install_dir}/Rakefile"
end
