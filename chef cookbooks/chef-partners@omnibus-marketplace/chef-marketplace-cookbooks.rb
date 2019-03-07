name "chef-marketplace-cookbooks"
license :project_license
skip_transitive_dependency_licensing true

source path: "#{project.files_path}/#{name}"

dependency "berkshelf-no-depselector"
dependency "chef-marketplace-gem"

build do
  command "#{install_dir}/embedded/bin/berks vendor #{install_dir}/embedded/cookbooks --berksfile=./chef-marketplace/Berksfile",
          env: { "RUBYOPT"         => nil,
                 "BUNDLE_BIN_PATH" => nil,
                 "BUNDLE_GEMFILE"  => nil,
                 "GEM_PATH"        => nil,
                 "GEM_HOME"        => nil }

  # Ensure cookbooks are readable so non-root chef-marketplace-ctl commands work
  command "chmod -R a+r #{install_dir}/embedded/cookbooks"

  erb source: "single-recipe.json.erb",
      dest: "#{install_dir}/embedded/cookbooks/dna.json",
      vars: { recipe: "chef-marketplace::default" }

  erb source: "single-recipe.json.erb",
      dest: "#{install_dir}/embedded/cookbooks/show-config.json",
      vars: { recipe: "chef-marketplace::show_config" }

  erb source: "solo.rb.erb",
      dest: "#{install_dir}/embedded/cookbooks/solo.rb"

  erb source: "non_root_solo.rb.erb",
      dest: "#{install_dir}/embedded/cookbooks/non_root_solo.rb"
end
