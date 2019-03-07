name "postgresql92"
default_version "9.2.10" # Chef Server 12.2 uses 9.2.10
license "PostgreSQL"
license_file "COPYRIGHT"

dependency "zlib"
dependency "openssl"
dependency "libedit"
dependency "ncurses"

version "9.2.10" do
  source md5: "7b81646e2eaf67598d719353bf6ee936"
end

source url: "http://ftp.postgresql.org/pub/source/v#{version}/postgresql-#{version}.tar.bz2"
relative_path "postgresql-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  command "./configure" \
           " --prefix=#{install_dir}/embedded" \
           " --with-libedit-preferred" \
           " --with-openssl" \
           " --with-includes=#{install_dir}/embedded/include" \
           " --with-libraries=#{install_dir}/embedded/lib", env: env
  make "-j #{workers}", env: env
  make "-C src/bin install", env: env
  make "-C src/include install", env: env
  make "-C src/interfaces install", env: env
  make "-C doc install", env: env
end
