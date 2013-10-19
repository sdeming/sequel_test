require 'java'
require File.expand_path('../../jars/postgresql-9.2-1002.jdbc4.jar', __FILE__)

DATABASE_CONFIG = {
  development: {
    adapter:  'jdbc',
    encoding: 'unicode',
    host:     'localhost',
    uri:      'postgresql:sequel_test',
    database: 'sequel_test',
    username: 'scott',
    password: 'scott'
  }
}
