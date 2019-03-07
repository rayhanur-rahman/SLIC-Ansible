#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'seth/config'
require 'seth/log'
require 'seth/mixin/params_validate'
require 'seth/version_constraint/platform'

# This file depends on nearly every provider in seth, but requiring them
# directly causes circular requires resulting in uninitialized constant errors.
# Therefore, we do the includes inline rather than up top.
require 'seth/provider'


class Seth
  class Platform

    class << self
      attr_writer :platforms

      def platforms
        @platforms ||= begin
          require 'seth/providers'

          {
            :mac_os_x => {
              :default => {
                :package => Seth::Provider::Package::Macports,
                :service => Seth::Provider::Service::Macosx,
                :user => Seth::Provider::User::Dscl,
                :group => Seth::Provider::Group::Dscl
              }
            },
            :mac_os_x_server => {
              :default => {
                :package => Seth::Provider::Package::Macports,
                :service => Seth::Provider::Service::Macosx,
                :user => Seth::Provider::User::Dscl,
                :group => Seth::Provider::Group::Dscl
              }
            },
            :freebsd => {
              :default => {
                :group   => Seth::Provider::Group::Pw,
                :service => Seth::Provider::Service::Freebsd,
                :user    => Seth::Provider::User::Pw,
                :cron    => Seth::Provider::Cron
              }
            },
            :ubuntu   => {
              :default => {
                :service => Seth::Provider::Service::Debian,
                :cron => Seth::Provider::Cron,
                :mdadm => Seth::Provider::Mdadm
              },
              ">= 11.10" => {
                :ifconfig => Seth::Provider::Ifconfig::Debian
              },
              ">= 13.10" => {
                :service => Seth::Provider::Service::Upstart,
              }
            },
            :gcel   => {
              :default => {
                :service => Seth::Provider::Service::Debian,
                :cron => Seth::Provider::Cron,
                :mdadm => Seth::Provider::Mdadm
              }
            },
            :linaro   => {
              :default => {
                :service => Seth::Provider::Service::Debian,
                :cron => Seth::Provider::Cron,
                :mdadm => Seth::Provider::Mdadm
              }
            },
            :raspbian   => {
              :default => {
                :service => Seth::Provider::Service::Debian,
                :cron => Seth::Provider::Cron,
                :mdadm => Seth::Provider::Mdadm
              }
            },
            :linuxmint   => {
              :default => {
                :service => Seth::Provider::Service::Upstart,
                :cron => Seth::Provider::Cron,
                :mdadm => Seth::Provider::Mdadm
              }
            },
            :debian => {
              :default => {
                :service => Seth::Provider::Service::Debian,
                :cron => Seth::Provider::Cron,
                :mdadm => Seth::Provider::Mdadm
              },
              ">= 6.0" => {
                :service => Seth::Provider::Service::Insserv
              },
              ">= 7.0" => {
                :ifconfig => Seth::Provider::Ifconfig::Debian
              }
            },
            :xenserver   => {
              :default => {
                :service => Seth::Provider::Service::Redhat,
                :cron => Seth::Provider::Cron,
                :package => Seth::Provider::Package::Yum,
                :mdadm => Seth::Provider::Mdadm
              }
            },
            :xcp   => {
              :default => {
                :service => Seth::Provider::Service::Redhat,
                :cron => Seth::Provider::Cron,
                :package => Seth::Provider::Package::Yum,
                :mdadm => Seth::Provider::Mdadm
              }
            },
            :centos   => {
              :default => {
                :service => Seth::Provider::Service::Redhat,
                :cron => Seth::Provider::Cron,
                :package => Seth::Provider::Package::Yum,
                :mdadm => Seth::Provider::Mdadm,
                :ifconfig => Seth::Provider::Ifconfig::Redhat
              }
            },
            :amazon   => {
              :default => {
                :service => Seth::Provider::Service::Redhat,
                :cron => Seth::Provider::Cron,
                :package => Seth::Provider::Package::Yum,
                :mdadm => Seth::Provider::Mdadm
              }
            },
            :scientific => {
              :default => {
                :service => Seth::Provider::Service::Redhat,
                :cron => Seth::Provider::Cron,
                :package => Seth::Provider::Package::Yum,
                :mdadm => Seth::Provider::Mdadm
              }
            },
            :fedora   => {
              :default => {
                :service => Seth::Provider::Service::Redhat,
                :cron => Seth::Provider::Cron,
                :package => Seth::Provider::Package::Yum,
                :mdadm => Seth::Provider::Mdadm,
                :ifconfig => Seth::Provider::Ifconfig::Redhat
              }
            },
            :opensuse     => {
              :default => {
                :service => Seth::Provider::Service::Redhat,
                :cron => Seth::Provider::Cron,
                :package => Seth::Provider::Package::Zypper,
                :group => Seth::Provider::Group::Suse
              },
              # Only OpenSuSE 12.3+ should use the Usermod group provider:
              ">= 12.3" => {
                :group => Seth::Provider::Group::Usermod
              }
            },
            :suse     => {
              :default => {
                :service => Seth::Provider::Service::Redhat,
                :cron => Seth::Provider::Cron,
                :package => Seth::Provider::Package::Zypper,
                :group => Seth::Provider::Group::Suse
              }
            },
            :oracle  => {
              :default => {
                :service => Seth::Provider::Service::Redhat,
                :cron => Seth::Provider::Cron,
                :package => Seth::Provider::Package::Yum,
                :mdadm => Seth::Provider::Mdadm
              }
            },
            :redhat   => {
              :default => {
                :service => Seth::Provider::Service::Redhat,
                :cron => Seth::Provider::Cron,
                :package => Seth::Provider::Package::Yum,
                :mdadm => Seth::Provider::Mdadm,
                :ifconfig => Seth::Provider::Ifconfig::Redhat
              }
            },
            :ibm_powerkvm   => {
              :default => {
                :service => Seth::Provider::Service::Redhat,
                :cron => Seth::Provider::Cron,
                :package => Seth::Provider::Package::Yum,
                :mdadm => Seth::Provider::Mdadm,
                :ifconfig => Seth::Provider::Ifconfig::Redhat
              }
            },
            :cloudlinux   => {
              :default => {
                :service => Seth::Provider::Service::Redhat,
                :cron => Seth::Provider::Cron,
                :package => Seth::Provider::Package::Yum,
                :mdadm => Seth::Provider::Mdadm,
                :ifconfig => Seth::Provider::Ifconfig::Redhat
              }
            },
            :gentoo   => {
              :default => {
                :package => Seth::Provider::Package::Portage,
                :service => Seth::Provider::Service::Gentoo,
                :cron => Seth::Provider::Cron,
                :mdadm => Seth::Provider::Mdadm
              }
            },
            :arch   => {
              :default => {
                :package => Seth::Provider::Package::Pacman,
                :service => Seth::Provider::Service::Systemd,
                :cron => Seth::Provider::Cron,
                :mdadm => Seth::Provider::Mdadm
              }
            },
            :mswin => {
              :default => {
                :env =>  Seth::Provider::Env::Windows,
                :service => Seth::Provider::Service::Windows,
                :user => Seth::Provider::User::Windows,
                :group => Seth::Provider::Group::Windows,
                :mount => Seth::Provider::Mount::Windows,
                :batch => Seth::Provider::Batch,
                :powershell_script => Seth::Provider::PowershellScript
              }
            },
            :mingw32 => {
              :default => {
                :env =>  Seth::Provider::Env::Windows,
                :service => Seth::Provider::Service::Windows,
                :user => Seth::Provider::User::Windows,
                :group => Seth::Provider::Group::Windows,
                :mount => Seth::Provider::Mount::Windows,
                :batch => Seth::Provider::Batch,
                :powershell_script => Seth::Provider::PowershellScript
              }
            },
            :windows => {
              :default => {
                :env =>  Seth::Provider::Env::Windows,
                :service => Seth::Provider::Service::Windows,
                :user => Seth::Provider::User::Windows,
                :group => Seth::Provider::Group::Windows,
                :mount => Seth::Provider::Mount::Windows,
                :batch => Seth::Provider::Batch,
                :powershell_script => Seth::Provider::PowershellScript
              }
            },
            :solaris  => {},
            :openindiana => {
              :default => {
                :mount => Seth::Provider::Mount::Solaris,
                :service => Seth::Provider::Service::Solaris,
                :package => Seth::Provider::Package::Ips,
                :cron => Seth::Provider::Cron::Solaris,
                :group => Seth::Provider::Group::Usermod
              }
            },
            :opensolaris => {
              :default => {
                :mount => Seth::Provider::Mount::Solaris,
                :service => Seth::Provider::Service::Solaris,
                :package => Seth::Provider::Package::Ips,
                :cron => Seth::Provider::Cron::Solaris,
                :group => Seth::Provider::Group::Usermod
              }
            },
            :nexentacore => {
              :default => {
                :mount => Seth::Provider::Mount::Solaris,
                :service => Seth::Provider::Service::Solaris,
                :package => Seth::Provider::Package::Solaris,
                :cron => Seth::Provider::Cron::Solaris,
                :group => Seth::Provider::Group::Usermod
              }
            },
            :omnios => {
              :default => {
                :mount => Seth::Provider::Mount::Solaris,
                :service => Seth::Provider::Service::Solaris,
                :package => Seth::Provider::Package::Ips,
                :cron => Seth::Provider::Cron::Solaris,
                :group => Seth::Provider::Group::Usermod,
                :user => Seth::Provider::User::Solaris,
              }
            },
            :solaris2 => {
              :default => {
                :mount => Seth::Provider::Mount::Solaris,
                :service => Seth::Provider::Service::Solaris,
                :package => Seth::Provider::Package::Ips,
                :cron => Seth::Provider::Cron::Solaris,
                :group => Seth::Provider::Group::Usermod,
                :user => Seth::Provider::User::Solaris,
              },
              "< 5.11" => {
                :mount => Seth::Provider::Mount::Solaris,
                :service => Seth::Provider::Service::Solaris,
                :package => Seth::Provider::Package::Solaris,
                :cron => Seth::Provider::Cron::Solaris,
                :group => Seth::Provider::Group::Usermod,
                :user => Seth::Provider::User::Solaris,
              }
            },
            :smartos => {
              :default => {
                :mount => Seth::Provider::Mount::Solaris,
                :service => Seth::Provider::Service::Solaris,
                :package => Seth::Provider::Package::SmartOS,
                :cron => Seth::Provider::Cron::Solaris,
                :group => Seth::Provider::Group::Usermod
              }
            },
            :netbsd => {
              :default => {
                :service => Seth::Provider::Service::Freebsd,
                :group => Seth::Provider::Group::Groupmod
              }
            },
            :openbsd => {
              :default => {
                :group => Seth::Provider::Group::Usermod
              }
            },
            :hpux => {
              :default => {
                :group => Seth::Provider::Group::Usermod
              }
            },
            :aix => {
              :default => {
                :group => Seth::Provider::Group::Aix,
                :mount => Seth::Provider::Mount::Aix,
                :ifconfig => Seth::Provider::Ifconfig::Aix,
                :cron => Seth::Provider::Cron::Aix,
                :package => Seth::Provider::Package::Aix
              }
            },
            :default => {
              :file => Seth::Provider::File,
              :directory => Seth::Provider::Directory,
              :link => Seth::Provider::Link,
              :template => Seth::Provider::Template,
              :remote_directory => Seth::Provider::RemoteDirectory,
              :execute => Seth::Provider::Execute,
              :mount => Seth::Provider::Mount::Mount,
              :script => Seth::Provider::Script,
              :service => Seth::Provider::Service::Init,
              :perl => Seth::Provider::Script,
              :python => Seth::Provider::Script,
              :ruby => Seth::Provider::Script,
              :bash => Seth::Provider::Script,
              :csh => Seth::Provider::Script,
              :user => Seth::Provider::User::Useradd,
              :group => Seth::Provider::Group::Gpasswd,
              :http_request => Seth::Provider::HttpRequest,
              :route => Seth::Provider::Route,
              :ifconfig => Seth::Provider::Ifconfig,
              :ruby_block => Seth::Provider::RubyBlock,
              :whyrun_safe_ruby_block => Seth::Provider::WhyrunSafeRubyBlock,
              :erl_call => Seth::Provider::ErlCall,
              :log => Seth::Provider::Log::sethLog
            }
          }
        end
      end

      include Seth::Mixin::ParamsValidate

      def find(name, version)
        provider_map = platforms[:default].clone

        name_sym = name
        if name.kind_of?(String)
          name.downcase!
          name.gsub!(/\s/, "_")
          name_sym = name.to_sym
        end

        if platforms.has_key?(name_sym)
          platform_versions = platforms[name_sym].select {|k, v| k != :default }
          if platforms[name_sym].has_key?(:default)
            provider_map.merge!(platforms[name_sym][:default])
          end
          platform_versions.each do |platform_version, provider|
            begin
              version_constraint = Seth::VersionConstraint::Platform.new(platform_version)
              if version_constraint.include?(version)
                Seth::Log.debug("Platform #{name.to_s} version #{version} found")
                provider_map.merge!(provider)
              end
            rescue Seth::Exceptions::InvalidPlatformVersion
              Seth::Log.debug("seth::Version::Comparable does not know how to parse the platform version: #{version}")
            end
          end
        else
          Seth::Log.debug("Platform #{name} not found, using all defaults. (Unsupported platform?)")
        end
        provider_map
      end

      def find_platform_and_version(node)
        platform = nil
        version = nil

        if node[:platform]
          platform = node[:platform]
        elsif node.attribute?("os")
          platform = node[:os]
        end

        raise ArgumentError, "Cannot find a platform for #{node}" unless platform

        if node[:platform_version]
          version = node[:platform_version]
        elsif node[:os_version]
          version = node[:os_version]
        elsif node[:os_release]
          version = node[:os_release]
        end

        raise ArgumentError, "Cannot find a version for #{node}" unless version

        return platform, version
      end

      def provider_for_resource(resource, action=:nothing)
        node = resource.run_context && resource.run_context.node
        raise ArgumentError, "Cannot find the provider for a resource with no run context set" unless node
        provider = find_provider_for_node(node, resource).new(resource, resource.run_context)
        provider.action = action
        provider
      end

      def provider_for_node(node, resource_type)
        raise NotImplementedError, "#{self.class.name} no longer supports #provider_for_node"
        find_provider_for_node(node, resource_type).new(node, resource_type)
      end

      def find_provider_for_node(node, resource_type)
        platform, version = find_platform_and_version(node)
        find_provider(platform, version, resource_type)
      end

      def set(args)
        validate(
          args,
          {
            :platform => {
              :kind_of => Symbol,
              :required => false,
            },
            :version => {
              :kind_of => String,
              :required => false,
            },
            :resource => {
              :kind_of => Symbol,
            },
            :provider => {
              :kind_of => [ String, Symbol, Class ],
            }
          }
        )
        if args.has_key?(:platform)
          if args.has_key?(:version)
            if platforms.has_key?(args[:platform])
              if platforms[args[:platform]].has_key?(args[:version])
                platforms[args[:platform]][args[:version]][args[:resource].to_sym] = args[:provider]
              else
                platforms[args[:platform]][args[:version]] = {
                  args[:resource].to_sym => args[:provider]
                }
              end
            else
              platforms[args[:platform]] = {
                args[:version] => {
                  args[:resource].to_sym => args[:provider]
                }
              }
            end
          else
            if platforms.has_key?(args[:platform])
              if platforms[args[:platform]].has_key?(:default)
                platforms[args[:platform]][:default][args[:resource].to_sym] = args[:provider]
              else
                platforms[args[:platform]] = { :default => { args[:resource].to_sym => args[:provider] } }
              end
            else
              platforms[args[:platform]] = {
                :default => {
                  args[:resource].to_sym => args[:provider]
                }
              }
            end
          end
        else
          if platforms.has_key?(:default)
            platforms[:default][args[:resource].to_sym] = args[:provider]
          else
            platforms[:default] = {
              args[:resource].to_sym => args[:provider]
            }
          end
        end
      end

      def find_provider(platform, version, resource_type)
        provider_klass = explicit_provider(platform, version, resource_type) ||
                         platform_provider(platform, version, resource_type) ||
                         resource_matching_provider(platform, version, resource_type)

        raise ArgumentError, "Cannot find a provider for #{resource_type} on #{platform} version #{version}" if provider_klass.nil?

        provider_klass
      end

      private

        def explicit_provider(platform, version, resource_type)
          resource_type.kind_of?(Seth::Resource) ? resource_type.provider : nil
        end

        def platform_provider(platform, version, resource_type)
          pmap = Seth::Platform.find(platform, version)
          rtkey = resource_type.kind_of?(Seth::Resource) ? resource_type.resource_name.to_sym : resource_type
          pmap.has_key?(rtkey) ? pmap[rtkey] : nil
        end

        def resource_matching_provider(platform, version, resource_type)
          if resource_type.kind_of?(Seth::Resource)
            begin
              Seth::Provider.const_get(resource_type.class.to_s.split('::').last)
            rescue NameError
              nil
            end
          else
            nil
          end
        end

    end
  end
end
