
rabbitmq Mash.new unless attribute?('rabbitmq')

rabbitmq["vhosts"] = Mash.new unless rabbitmq.has_key?("vhosts")
rabbitmq["users"] = Mash.new unless rabbitmq.has_key?("users")

