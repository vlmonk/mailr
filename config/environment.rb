# Be sure to restart your webserver when you modify this file.

# Uncomment below to force Rails into production mode
# (Use only when you can't set environment variables through your web/app server)
# ENV['RAILS_ENV'] = 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/vendor/ezcrypto-0.1.1/lib )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  config.action_controller.session_store = :active_record_store

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc
  
  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  # config.active_record.schema_format = :ruby

  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below

default_config_path = 'config/default_site'
default_config = File.join(RAILS_ROOT, default_config_path)
require default_config
begin
  require File.join(RAILS_ROOT, 'config/site')
  CDF::CONFIG.update(CDF::LOCALCONFIG) if CDF::LOCALCONFIG
rescue LoadError
  STDERR.puts 'WARNING: config/site.rb not found, using default settings from ' + default_config_path
end

require 'tmail_patch'
require 'gettext_extension'
$KCODE = 'u'
require 'jcode'

# set UTF8 as a client interface to Database
RAILS_DEFAULT_LOGGER.debug("Using MySQL Version #{CDF::CONFIG[:mysql_version]}")
ActiveRecord::Base.connection.execute("SET NAMES utf8", 'Set Client encoding to UTF8') if CDF::CONFIG[:mysql_version] == '4.1'
ActiveRecord::Base.connection.execute("set character set utf8", 'Set Connection encoding to UTF8') if CDF::CONFIG[:mysql_version] == '4.1'

require 'imapmailbox'
[IMAPMailbox, IMAPFolderList, IMAPFolder].each { |mod| mod.logger ||= RAILS_DEFAULT_LOGGER }
