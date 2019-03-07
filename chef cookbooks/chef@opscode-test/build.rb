#
# Cookbook Name:: erlang_binary
# Recipe:: build
#
# Copyright 2010, Opscode, Inc.
#
# All rights reserved - Do Not Redistribute
#

erlang_prereq = ["build-essential", "libssl-dev", "libncurses5-dev"]
erlang_version = "otp_R14B"

configure_str = "./configure --enable-dynamic-ssl-lib --enable-shared-zlib --enable-smp-support --enable-kernel-poll --enable-hipe --enable-threads --without-javac" +  (node[:kernel][:machine]=="x86_64" ? "--enable-m64-build" : "")
erlang_builddir = "/usr/local/lib/erlang_build_dir"
erlang_source_name = "otp_src_R14B.tar.gz"
erlang_remote_source = "http://s3.amazonaws.com/opscode-erlang/#{erlang_source_name}"
erlang_local_source = "#{erlang_builddir}/#{erlang_source_name}"

# install pre-requisites
erlang_prereq.each do |n|
  apt_package n do
    action :install
  end
end

directory erlang_builddir do
  owner "root"
  mode 0755
  action :create
  not_if "test -d #{erlang_builddir}"
end

remote_file erlang_local_source do
  source #{erlang_remote_source}
  action :create_if_missing
end

execute "erlang-source-unpack" do
  cwd erlang_builddir
  command = "tar zxvf #{erlang_source_name}"
end

execute "erlang-configure" do
  cwd "#{erlang_builddir}/otp"
  command = configure_str
end

execute "erlang-build" do
  cwd "#{erlang_builddir}/otp"
  command = "make && make install"
end
