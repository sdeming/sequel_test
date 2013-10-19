require 'bundler/setup'
require File.expand_path('../config/database', __FILE__)

db = Sequel.connect(DB_CONFIG)
db[:notes].delete
db[:notes].insert(:title => "Hello", :content => "A wee bit of text...")

dataset = db[:notes].select_all.limit(0...10)
puts dataset.sql
puts dataset.all


