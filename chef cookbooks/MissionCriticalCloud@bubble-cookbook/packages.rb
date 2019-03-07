# Packages for virt-manager and kvm

package 'epel-release'

package %w(centos-release-qemu-ev vlgothic-fonts adwaita-gtk3-theme
           kvm virt-manager libvirt virt-install qemu-kvm xauth
           dejavu-lgc-sans-fonts)

# Extra tools
package %w(git virt-top screen vim openssh-askpass supervisor deltarpm sshpass
           byobu bash-completion nmap zsh)

# libguestfs-tools for manipulating images
package 'libguestfs-tools'

# Python packages for the deploy scripts
package %w(python-pip python-bottle python-argparse python-jinja2)

# Packages for running marvin (compile scripts) on the bubble itself
# remove maven yum package if present
package 'maven' do
  action :remove
end
include_recipe 'maven::default'

package %w(python-paramiko ws-commons-util genisoimage gcc python MySQL-python
           mariadb mysql-connector-python)

# required java & tools
# Upgrade openjdk to 'latest' due to enhanced crypto support
package 'java-1.8.0-openjdk-devel.x86_64' do
  action :upgrade
end

package %w(apache-commons-daemon-jsvc libffi-devel)

# tools & clients
package %w(mariadb-server nc nfs-utils openssh-clients openssl-devel rpm-build
           setroubleshoot wget)

# python & ruby tooling
package %w(python-devel python-ecdsa python-setuptools rubygems)

# AWS cli, upgrade to latest each run
python_pip 'awscli' do
  action :upgrade
end
