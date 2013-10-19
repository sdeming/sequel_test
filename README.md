Sequel Testing
==============

Synopsis
--------
Running database specific tests can be a pain the ass because you need an instance of the database engines running and
available in order to see the database interaction actually work. Any attempt at mocking these kinds of things will be
a fruitless effort. This project is my attempt at making something where I can write simple database tests to expose
and attempt to work around various issues that crop up while developing applications.

At the moment there are two main database targets, one is used because it seems to be very well supported and the other
is what I am primarily targeting in the real world: PostgreSQL and Oracle, respectively.

Getting Started
---------------
Bundler is used here to fetch the latest Sequel gem release. So you'll have to bundle install; I recommend using the
--path directive to keep things nice and orderly:
```
bundle install --path=vendor
```

There are two important environment variables you'll need to know about:

* APP_ENV defines the environment similar to RAILS_ENV and defaults to development.
* DB_ENV defines which database to use; oracle or postgresql are available options defaulting to postgresql.

Oracle configuration is represented in the config/oracle.rb file while the PostgreSQL configuration is represented in
the config/postgresql.rb file. In the ruby code, simply load config/database.rb and based on the APP_ENV and DB_ENV
variables the correct configuration will be loaded as well as the necessary jdbc jar files (found in ./jars).

Now you'll need the databases. To begin with, clean databases should be created in all of the test targets: oracle and
postgresql. Their respective configurations should be written to the files in config.

With the clean set of databases, run the migration script:
```
APP_ENV=development DB_ENV=postgresql jruby migrate.rb migrations/
APP_ENV=development DB_ENV=oracle jruby migrate.rb migrations/
```

Now you can run any of the individual test cases for each target.

As an example, run the clobs_with_limit.rb script first with postgresql:
```
APP_ENV=development DB_ENV=postgresql jruby clobs_with_limit.rb
```
Which should yield something along the lines of:
```
SELECT * FROM "notes" LIMIT 10 OFFSET 0
{:id=>11, :title=>"Hello", :content=>"A wee bit of text..."}
```
And then with oracle:
```
APP_ENV=development DB_ENV=oracle jruby clobs_with_limit.rb
```
Which yields the error:
```
SELECT * FROM (SELECT "ID", "TITLE", "CONTENT" FROM (SELECT "NOTES".*, ROW_NUMBER() OVER (ORDER BY "ID", "TITLE", "CONTENT") "X_SEQUEL_ROW_NUMBER_X" FROM "NOTES") "T1" WHERE ("X_SEQUEL_ROW_NUMBER_X" > 0) ORDER BY "X_SEQUEL_ROW_NUMBER_X") "T1" WHERE (ROWNUM <= 10)
Sequel::DatabaseError: Java::JavaSql::SQLSyntaxErrorException: ORA-00932: inconsistent datatypes: expected - got CLOB

  raise_error at C:/Users/Scott/CODE/sequel_test/vendor/jruby/1.9/gems/sequel-4.3.0/lib/sequel/database/misc.rb:402
    statement at C:/Users/Scott/CODE/sequel_test/vendor/jruby/1.9/gems/sequel-4.3.0/lib/sequel/adapters/jdbc.rb:604
      execute at C:/Users/Scott/CODE/sequel_test/vendor/jruby/1.9/gems/sequel-4.3.0/lib/sequel/adapters/jdbc.rb:259
         hold at C:/Users/Scott/CODE/sequel_test/vendor/jruby/1.9/gems/sequel-4.3.0/lib/sequel/connection_pool/threaded.rb:104
  synchronize at C:/Users/Scott/CODE/sequel_test/vendor/jruby/1.9/gems/sequel-4.3.0/lib/sequel/database/connecting.rb:234
      execute at C:/Users/Scott/CODE/sequel_test/vendor/jruby/1.9/gems/sequel-4.3.0/lib/sequel/adapters/jdbc.rb:258
      execute at C:/Users/Scott/CODE/sequel_test/vendor/jruby/1.9/gems/sequel-4.3.0/lib/sequel/dataset/actions.rb:793
   fetch_rows at C:/Users/Scott/CODE/sequel_test/vendor/jruby/1.9/gems/sequel-4.3.0/lib/sequel/adapters/jdbc.rb:671
         each at C:/Users/Scott/CODE/sequel_test/vendor/jruby/1.9/gems/sequel-4.3.0/lib/sequel/dataset/actions.rb:143
          all at C:/Users/Scott/CODE/sequel_test/vendor/jruby/1.9/gems/sequel-4.3.0/lib/sequel/dataset/actions.rb:46
       (root) at clobs_with_limit.rb:10
```
The relevent fact here is:
  Sequel::DatabaseError: Java::JavaSql::SQLSyntaxErrorException: ORA-00932: *inconsistent datatypes: expected - got CLOB*

This occurs due to the ROW_NUMBER() OVER () clause that requires an order by list. In Oracle you cannot order by a CLOB,
nor would you really want to. This makes it impossible, using the current implementation of limit for Oracle, to page
any dataset that includes clobs.

