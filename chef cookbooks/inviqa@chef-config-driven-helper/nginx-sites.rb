include_recipe 'config-driven-helper::nginx-compat-disable-default'
include_recipe 'config-driven-helper::nginx-compat-https-map-emulation'

node['nginx']['sites'].each do |name, site_attrs|
  definition = app_vhost name do
    site site_attrs
    server_type 'nginx'
  end

  # Different versions of Chef return definitions differently
  if definition.is_a? Chef::Recipe
    site = definition.params[:site]
  else
    site = definition
  end

  begin
    begin
      values = node.attribute.combined_override['nginx']['sites'][name]
    rescue
      values = {}
    end
    ::Chef::Mixin::DeepMerge.hash_only_merge!(values, site)
    node.force_override!['nginx']['sites'][name] = values
  rescue
    # Chef 11.10 compat
    ::Chef::Mixin::DeepMerge.hash_only_merge!(node.force_override['nginx']['sites'][name], site)
  end
end
