module ConfigDrivenHelper
  module Util
    extend self

    # though this is used in this cookbook, it may also be used externally as well
    def immutablemash_to_hash(immutable_mash)
      result = immutable_mash.to_hash.dup
      result.each_pair do |key, value|
        if value.is_a?(Chef::Node::ImmutableMash)
          result[key] = immutablemash_to_hash(value)
        end
      end
    end

    def merge_default_shared_site(node, name, site, server_type = nil)
      type = server_type || site['server_type']
      raise "Unsupported vhost type (#{type})" unless ['nginx', 'apache'].include? type

      site = ConfigDrivenHelper::Util::immutablemash_to_hash(site) if site.is_a?(Chef::Node::ImmutableMash)

      if site['inherits']
        site = ::Chef::Mixin::DeepMerge.hash_only_merge(
          ConfigDrivenHelper::Util::immutablemash_to_hash(node[type]['shared_config'][site['inherits']]),
          site)
      end

      site = ::Chef::Mixin::DeepMerge.hash_only_merge(ConfigDrivenHelper::Util::immutablemash_to_hash(node["#{type}-sites"]), site)
      site['server_name'] ||= name
      site['protocols'] ||= ['http']
      site['server_type'] = type

      # BC attribute porting
      site['http_auth']['type'] = 'basic' if site['basic_username']

      site
    end
  end
end
