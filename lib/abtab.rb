require 'abtab/driver'

module Abtab
  REGISTERED_DRIVERS = {}

  def self.register schema, driver
    REGISTERED_DRIVERS[schema] = driver
  end

  def self.open thing
    if thing !~ /^.+?:\/\//
      return self.open_file thing
    end

    viable_drivers = REGISTERED_DRIVERS.keys.select do |schema|
      thing.start_with? schema
    end

    if 0 == viable_drivers.size
      raise "Error: there is no registered driver for url: #{thing}"
    end

    if 1 == viable_drivers.size
      REGISTERED_DRIVERS[viable_drivers.first].new thing
    end
  end

  def self.read_handle uri
    driver = self.open uri
    driver.open_for_reading
    driver
  end

  def self.write_handle uri
    driver = self.open uri
    driver.open_for_writing
    driver
  end

  def self.open_file thing
    # TODO: put in some more 'magick' -- use some hueristics to figure out the likely format by looking at the first few lines...
    if thing =~ /.tab$/
      return self.open "tab://#{thing}"
    end

    if thing =~ /.csv$/
      return self.open "csv://#{thing}"
    end

    # tab delimited is the default
    return self.open "tab://#{thing}"
  end
end

Dir[File.dirname(__FILE__) + '/abtab/drivers/**/*.rb' ].each do |f|
  require f
end
