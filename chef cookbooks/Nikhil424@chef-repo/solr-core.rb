include_recipe 'solr_6::install'

solrcoretest_solrcore 'secops' do
  action :create
end
