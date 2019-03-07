name        'hbase_regionserver'
description 'runs an hbase-regionserver in fully-distributed mode.'

run_list %w[
  role[hadoop]
  zookeeper::client

  hbase::default
  hbase::regionserver
  hbase::config_files
]
