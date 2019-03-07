require "json"
require "sequel"
require "time"
require "logger"

class ActionsTrimmer
  attr_accessor :log, :options, :db

  def initialize(opts = {})
    @options = default_options.merge(opts)
    @log = Logger.new(options[:log_file])
    @db = Sequel.postgres("actions",
                          user: options[:user],
                          password: options[:password],
                          host: options[:host])
  end

  def run
    log.info "Starting Analytics Actions database trimmer.."
    log.info "Maximum allowed database size: #{options[:db_max_size_gb]}GB"
    log.info "Average activity entry size: #{options[:avg_activity_size_kb]}KB"
    log.info "Activities since last run: #{interval_activities}"
    log.info "Maximum allowed activities: #{allowed_activities}"
    log.info "#{delete_activities} activities deleted!"
  end

  private

  def default_options
    config = JSON.parse(File.read("/etc/opscode-analytics/opscode-analytics-running.json"))["analytics"]

    {
      user: config["actions"]["sql_user"],
      password: config["actions"]["sql_password"],
      host: "localhost",
      log_file: $stdout,
      db_max_size_gb: 1,
      avg_activity_size_kb: 20,
      interval: 4
    }
  end

  # Reduce the allowed activity count by the activities since our last run to
  # prevent overflowing
  def allowed_activities
    @allowed_activities ||= ((db_max_size_kb / options[:avg_activity_size_kb]) - interval_activities).to_i
  end

  def interval_seconds
    @interval_seconds ||= options[:interval].to_i * 60 * 60
  end

  # How many activities have happened since our last run
  def interval_activities
    last_run = Time.now - interval_seconds
    @interval_activities ||= db.from(:activities).where { recorded_at >= last_run }.count
  end

  def db_max_size_kb
    @db_max_size_kb ||= options[:db_max_size_gb] * 1_000_000
  end

  def delete_activities
    offset = db.from(:activities).reverse_order(:recorded_at).offset(allowed_activities).first
    if offset.is_a?(Hash)
      db.from(:activities).where { recorded_at <= offset[:recorded_at] }.delete
    else
      0
    end
  end
end
