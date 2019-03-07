name "cheffish-gem"
default_version "13.1.0"
license "Apache-2.0"
license_file "https://github.com/chef/cheffish/raw/master/LICENSE"

dependency "ruby"
dependency "rubygems"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  gem "install cheffish " \
      "--version #{version} " \
      "--no-ri --no-rdoc", env: env

  gem "install cheffish " \
      "--version #{version} " \
      "-i #{install_dir}/embedded/service/gem/ruby/2.4.0 " \
      "--no-ri --no-rdoc", env: env
end
