name "seiso_db"
description "Seiso database"
run_list "recipe[mysql::server]", "recipe[mysql::client]", "recipe[seiso-db]"
override_attributes(
  "mysql" => {
    "version" => "5.6"
  }
)
