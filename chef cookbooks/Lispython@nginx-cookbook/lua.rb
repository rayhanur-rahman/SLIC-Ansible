
default["nginx"]["lua"]["url"] = "https://github.com/chaoslawful/lua-nginx-module/archive/v0.7.14.tar.gz"
default["nginx"]["lua"]["check_sum"] = "2bef1742545880e5b472b9d8883defa5"
default["nginx"]["ngx_devel_kit"]["url"] = "https://github.com/simpl/ngx_devel_kit/archive/v0.2.18.tar.gz"
default["nginx"]["ngx_devel_kit"]["check_sum"] = "58cce12d9e46410fcc65b0d62bc60acc"

default["nginx"]["lua"]["packages"] = %w{luajit libluajit-5.1-2 libluajit-5.1-common libluajit-5.1-dev}


default['nginx']['lua']['jit']['lib'] = "/usr/lib"
default['nginx']['lua']['jit']['inc'] = "/usr/include/luajit-2.0"
