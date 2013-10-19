require 'bundler/setup'
require File.expand_path('../config/database', __FILE__)

Sequel.connect(DB_CONFIG) do |db|
  Sequel.extension :migration
  Sequel::Migrator.run db, ARGV[0]
end
