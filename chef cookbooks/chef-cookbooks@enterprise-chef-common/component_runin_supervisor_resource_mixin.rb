module ComponentRunitSupervisorResourceMixin
  def self.append_features(klass)
    klass.class_eval do
      resource_name :component_runit_supervisor
      actions :create, :delete
      default_action :create

      property :name, kind_of: String, name_property: true, required: true
      property :ctl_name, kind_of: String, required: true
      property :sysvinit_id, kind_of: String, default: 'SV'
      property :install_path, kind_of: String, required: true
    end
  end
end
