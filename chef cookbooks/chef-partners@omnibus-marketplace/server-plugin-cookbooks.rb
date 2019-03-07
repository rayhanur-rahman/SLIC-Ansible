name "server-plugin-cookbooks"
source path: "#{project.files_path}/#{name}"
license :project_license
skip_transitive_dependency_licensing true

build do
  sync project_dir, "#{install_dir}/embedded/server-plugin-cookbooks/"
end
