require 'digest'

module BCPC
  class NetworkIDGenerator
    def generate_id(mapping)
      hash = Digest::SHA256.new
      mapping.keys.sort.each {|k|
        hash.update mapping[k].to_s.force_encoding(Encoding::UTF_8)
      }
      hash.hexdigest
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  mapping_file = ARGV[0]
  if mapping_file.nil?
     $stderr.puts 'Supply a mapping file.'
     exit! 1
  end

  require 'json'
  g = BCPC::NetworkIDGenerator.new
  begin
    File.open(mapping_file) {|f|
      mapping = JSON::load f
      puts g.generate_id mapping
    }
  rescue Exception => e
    $stderr.puts e
  end
end
