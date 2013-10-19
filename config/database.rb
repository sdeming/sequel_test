require 'sequel'

APP_ENV = (ENV['APP_ENV'] || :development).to_sym
DB_ENV  = (ENV['DB_ENV']  || :postgresql).to_sym

begin
  require File.expand_path("../#{DB_ENV}", __FILE__)
rescue => x
  $stderr.puts "Unable to load database environment for #{DB_ENV.inspect}."
  $stderr.puts "  Reason: #{x.message}"
  exit(1)
end

DB_CONFIG = DATABASE_CONFIG[APP_ENV]
if DB_CONFIG.nil?
  $stderr.puts "Database configuration for #{APP_ENV.inspect} not found in #{DB_ENV.inspect}"
  exit(1)
end
