name "seiso_bus"
description "Seiso message bus"
run_list "recipe[rabbitmq]", "recipe[rabbitmq::user_management]", "recipe[rabbitmq::mgmt_console]"

override_attributes(
  "erlang" => {
    "install_method" => "package"
  },
  "rabbitmq" => {
    "packagebaseame" => "rabbitmq-server",
    "extension" => ".noarch.rpm",
    "version" => "3.4.0"
  }
)
