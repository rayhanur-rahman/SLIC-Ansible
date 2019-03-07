name "chef-marketplace"
maintainer "Chef Software, Inc. <partnereng@chef.io>"
homepage "http://www.chef.io"
license "Apache-2.0"
license_file "LICENSE"

install_dir "/opt/chef-marketplace"
build_version Omnibus::BuildVersion.semver
build_iteration 1

# NOTE: If you update ruby's minor version make sure you update the gem install
#       paths in the other software definitions.
override :ruby, version: "2.4.3"

# Pin to 13.6.0 until master gets more stable
override :'chef-gem', version: "13.6.0"

# Pin rubygems to 2.6.x because 2.7.x breaks bundlers gracefull install
override :rubygems, version: "2.6.14"

# Master points to an unreleased chef version (in current)
override :'berkshelf-no-depselector', version: "v6.3.1"

dependency "preparation"
dependency "postgresql92" # only the client
dependency "sequel-gem"
dependency "pg-gem"
dependency "server-plugin-cookbooks"
dependency "reckoner"
dependency "biscotti"
dependency "chef-gem"
dependency "cheffish-gem"
dependency "chef-marketplace-ctl"
dependency "chef-marketplace-gem"
dependency "chef-marketplace-cookbooks"
dependency "version-manifest"

exclude '\.git*'
exclude 'bundler\/git'

package :rpm do
  signing_passphrase ENV["OMNIBUS_RPM_SIGNING_PASSPHRASE"]
end
