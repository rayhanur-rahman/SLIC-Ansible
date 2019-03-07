if defined?(ChefSpec)
  def create_component_runit_supervisor(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new('component_runit_supervisor',
                                            'create', resource_name)
  end
end
