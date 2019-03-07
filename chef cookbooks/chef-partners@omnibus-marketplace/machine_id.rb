class Marketplace
  class Reckoner
    module MachineID
      def machine_uuid
        machine_id_contents["machine_uuid"]
      end

      def machine_salt
        machine_id_contents["machine_salt"]
      end

      def machine_id_file
        "/var/opt/chef-marketplace/reckoner/etc/machine-id.json"
      end

      def machine_id_contents
        if File.exist?(machine_id_file)
          Hash(JSON.load(File.read(machine_id_file)))
        else
          generate_machine_id
        end
      end

      def generate_machine_id
        contents = { "machine_uuid" => SecureRandom.uuid, "machine_salt" => SecureRandom.uuid }
        File.write(machine_id_file, contents.to_json)

        contents
      end
    end
  end
end
