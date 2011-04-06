require 'rubygems'

SPEC = Gem::Specification.new do |s|
  s.name = "abstract-tables"
  s.version = "1.0.4"
  s.date = '2011-02-15'
  s.authors = ["Kyle Burton"]
  s.email = "kyle.burton@gmail.com"
  s.platform = Gem::Platform::RUBY
  s.description = <<DESC
The best I could come up with was to just show you: 

  $ atcat dbi://pg/localhost/database_name/table_name csv://table_name.csv

That exports a table from Postgres into a comma separated value file.  You can 
read from or write to: tab, csv, dbi, etc.  You can opaquely treat any of those
'table of records' based sources as an opaque URI.  Want to read more?

   https://github.com/kyleburton/abstract-tables

DESC
  s.summary = "Table Abstraction as a URI : Record Streams, Filters, ETL Ginsu"
  s.homepage = "http://github.com/kyleburton/abstract-tables"
  s.files = %w[
    abstract-tables.gemspec
    bin/atcat
    bin/atview
    bin/atgrep
    introducing-abtab/README.textile
    lib/abtab/driver.rb
    lib/abtab/drivers/csv_driver.rb
    lib/abtab/drivers/dbi_driver.rb
    lib/abtab/drivers/tab_driver.rb
    lib/abtab/drivers/xls_driver.rb
    lib/abtab/filter/grep.rb
    lib/abtab/filter.rb
    lib/abtab.rb
    README.textile
    test/fixtures/files/file1.csv
    test/fixtures/files/file1.tab
  ]
  puts "all files: #{s.files.inspect}"
  s.executables = %w[atcat atview]
  s.require_paths = %w[lib bin]
  s.extra_rdoc_files = %w[README.textile] #  LICENSE]
  s.add_runtime_dependency('dbi', [">= 0.4.5"])
  s.add_runtime_dependency('spreadsheet', [">= 0.6.5.2"])
  s.add_runtime_dependency('fastercsv', [">= 1.5.4"])
  s.has_rdoc = false
end
