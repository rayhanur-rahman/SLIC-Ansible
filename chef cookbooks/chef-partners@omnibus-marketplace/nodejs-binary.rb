name "nodejs-binary"
default_version "8.9.1"

license "MIT"
license_file "LICENSE"
skip_transitive_dependency_licensing true

version "8.9.1" do
  source sha256: "0e49da19cdf4c89b52656e858346775af21f1953c308efbc803b665d6069c15c"
end

source url: "https://nodejs.org/dist/v#{version}/node-v#{version}-linux-x64.tar.gz"
relative_path "node-v#{version}-linux-x64"

build do
  mkdir "#{install_dir}/embedded/nodejs"
  sync "#{project_dir}/", "#{install_dir}/embedded/nodejs"
end
