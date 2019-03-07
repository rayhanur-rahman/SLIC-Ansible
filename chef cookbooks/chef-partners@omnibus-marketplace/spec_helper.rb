# Add the gem source to the load path for the specs
lib = File.expand_path("../../../chef-marketplace-gem/lib", __FILE__)
$LOAD_PATH.unshift(lib) if File.directory?(lib) && !$LOAD_PATH.include?(lib)

require "rspec"
require "omnibus-ctl"
require "pathname"
require "marketplace"
require "shellwords"

class OmnibusCtlTest
  attr_accessor :plugin, :name

  def initialize(plugin_name)
    @name = plugin_name
    path = Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), "../#{name}.rb")))
    raise "Could not find plugin at #{path.expand_path}" unless path.exist?
    @plugin = Omnibus::Ctl.new(path.basename.sub_ext("").to_s)
    plugin.load_file(path.expand_path.to_s)
  end

  def execute(command_with_args)
    # Add useless fake PATHS to ARGV
    ARGV.clear
    ARGV << "/embedded/bin/omnibus-ctl"
    ARGV << name
    ARGV << "/embedded/service/omnibus-ctl"

    # Separate command and args and add args to ARGV
    args = Shellwords.split(command_with_args)
    command = args.shift

    args.each { |a| ARGV << a }

    plugin.run(Array(command))
  end
end
