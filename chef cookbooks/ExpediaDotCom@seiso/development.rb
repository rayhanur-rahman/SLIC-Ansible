name "development"
description "Local development environment"
override_attributes(
  "mysql" => {
    "allow_remote_root" => true,
    "server_root_password" => "root"
  },
  "rabbitmq" => {
    "enabled_users" => [
      {
        "name" => "admin",
        "password" => "admin",
        "tag" => "administrator",
        "rights" => [
          {
            "vhost" => "/",
            "conf" => ".*",
            "read" => ".*",
            "write" => ".*"
          }
        ]
      },
      {
        "name" => "seiso",
        "password" => "seiso",
        "rights" => [
          {
            "vhost" => "/",
            "conf" => ".*",
            "read" => ".*",
            "write" => ".*"
          }
        ]
      }
    ]
  },
  "seiso_db" => {
    "sql_scripts" => [
      "create-tables.sql",
      "insert-reference-data.sql",
      "insert-sample-data.sql"
    ]
  }
)
