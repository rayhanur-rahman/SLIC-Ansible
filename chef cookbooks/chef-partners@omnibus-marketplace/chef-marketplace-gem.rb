name "chef-marketplace-gem"
license :project_license

dependency "ruby"
dependency "bundler"
dependency "pg-gem"

source path: "#{project.files_path}/#{name}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  delete "chef-marketplace-*.gem"

  gem "build chef-marketplace.gemspec", env: env

  gem "install chef-marketplace-*.gem --without development", env: env
  gem "install chef-marketplace-*.gem -i #{install_dir}/embedded/service/gem/ruby/2.4.0 --without development", env: env

  sync "#{project_dir}/spec", "#{install_dir}/embedded/service/chef-marketplace-gem/spec"
end
