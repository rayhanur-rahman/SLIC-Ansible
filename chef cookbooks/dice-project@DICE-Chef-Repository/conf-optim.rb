#
# Cookbook Name:: dice-h2020
# Recipe:: conf-optim
#
# Copyright 2016, XLAB d.o.o.
#
# Apache 2 license
#

# Install dependencies
# - matlab dependencies
required_packages = ['g++', 'libxmu6', 'libxt6', 'libxpm4', 'libxp6', 'unzip' ]
# - auxiliary tools dependencies
required_packages += ['python', 'python-virtualenv', 'python-dev']

required_packages.each do |pkg|
	package pkg do
		action :install
	end
end

# Obtain and install matlab
matlab_install_path = node["dice-h2020"]["conf-optim"]["matlab-installpath"]

remote_file '/tmp/matlab.zip' do
	source node["dice-h2020"]["conf-optim"]["matlab-url"]
	action :create_if_missing
end

bash 'matlab.zip' do
	cwd "/tmp"
	code <<-EOH
	    [[ -d matlab ]] && rm -rf matlab
	    mkdir -p matlab
	    cd matlab
		unzip -q -u ../matlab.zip
		EOH
	action :run
	not_if do ::File.exists?('/tmp/matlab/install') end
end

bash "install-matlab" do
	cwd "/tmp/matlab"
	code <<-EOH
		mkdir -p #{matlab_install_path}
		./install -destinationFolder #{matlab_install_path} -mode silent -agreeToLicense yes
		EOH
	action :run
	not_if do ::File.exists?(File.join(matlab_install_path, 'v85', 'bin', 'glnxa64', 
		'matlab_helper')) end
end

# Obtain and install Configuration Optimization
co_package_base_url = node["dice-h2020"]["conf-optim"]["release-url"]
co_src_package_url = node["dice-h2020"]["conf-optim"]["src-release-url"]
co_version = node["dice-h2020"]["conf-optim"]["co-version"]
co_package_url = "#{co_package_base_url}/#{co_version}/bin.zip"
co_install_path = node["dice-h2020"]["conf-optim"]["co-installpath"]


remote_file '/tmp/co.zip' do
	source co_package_url
	action :create_if_missing
end

remote_file '/tmp/co-src.zip' do
	source co_src_package_url
	action :create_if_missing
end

directory 'co-dir' do
	path ::File.join(co_install_path)
	action :create
end

directory 'co-conf-dir' do
	path ::File.join(co_install_path, "conf")
	action :create
end

bash 'install-co' do
	cwd "/tmp"
	code <<-EOH
		[[ -d co ]] && rm -rf co
		mkdir -p co
		cd co
		unzip -q -u ../co.zip

		cp bin/ubuntu64/main #{co_install_path}
		cp bin/ubuntu64/run_main.sh #{co_install_path}
		EOH
	action :run
end

# TODO temporary step before the utilities are packaged in the release
bash 'install-co-ext' do
	cwd "/tmp"
	code <<-EOH
		[[ -d co-src ]] && rm -rf co-src
		mkdir -p co-src
		cd co-src
		unzip -q -u ../co-src.zip
		cd $(ls)

		cp utils/merge_expconfig.py #{co_install_path}
		cp utils/requirements.txt ../utils-requirements.txt
		EOH
	action :run
end

python_runtime '2'

pip_requirements '/tmp/co-src/utils-requirements.txt'

template 'run_bo4co.sh' do
	source 'run_bo4co.sh.erb'
	path ::File.join(co_install_path, 'run_bo4co.sh')
	mode '0755'
	variables :co_install_path => co_install_path,
		:matlab_install_path => matlab_install_path
end

# TODO replace with a safer method of obtaining credentials
deployment_service_username = node["dice-h2020"]["deployment-service"]["username"]
deployment_service_password = node["dice-h2020"]["deployment-service"]["password"]
template 'config.yaml' do
	source 'co-config.yaml.erb'
	path ::File.join(co_install_path, 'conf', 'config.yaml')
	variables :deployment_service_url => node["dice-h2020"]["deployment-service"]["url"],
		:deployment_service_container => node["dice-h2020"]["conf-optim"]["ds-container"],
		:deployment_service_username => deployment_service_username,
		:deployment_service_password => deployment_service_password,
		:deployment_service_install_path => node["dice-h2020"]["deployment-service"]["tools-install-path"],
		:dmon_url => node["dice-h2020"]["d-mon"]["url"]
	action :create
end

cookbook_file 'app-config.yaml' do
	source 'co-app-config-sample.yaml'
	path ::File.join(co_install_path, 'conf', 'app-config.yaml')
	action :create
end

bash 'expconfig.yaml' do
	cwd co_install_path
	code <<-EOH
		./merge_expconfig.py \
		    -c conf/config.yaml \
		    -a conf/app-config.yaml \
		    -O conf/expconfig.yaml
		EOH
end
