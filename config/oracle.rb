require 'java'
require File.expand_path('../../jars/ojdbc6-11.2.0.3.jar', __FILE__)

DATABASE_CONFIG = {
  development: {
    adapter:  'jdbc',
    encoding: 'unicode',
    host:     'localhost',
    uri:      'oracle:thin:@localhost:1521/pdborcl',
    database: 'sequel',
    username: 'sequel',
    password: 'sequel'
  }
}
