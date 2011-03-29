require 'dbi'
require 'yaml'

class Abtab::Driver::DbiDriver < Abtab::Driver
  CREDENTIALS_RC_FILE = "#{ENV['HOME']}/.abtab.dbrc"

  DB_MODULES = {
    'Pg'      => { :require => 'Pg', :name => 'Pg' },
    'pg'      => { :require => 'pg', :name => 'Pg' },
    # TODO: test these
    #'mysql'   => 'mysql',
    #'Mysql'   => 'mysql',
    #'sqlite'  => 'sqlite3',
    #'SQLite'  => 'sqlite3',
    #'sqlite3' => 'sqlite3',
    #'SQLite3' => 'sqlite3',
  }

  def lookup_rc_default *keys
    #puts "LOOKUP: #{keys.inspect}"
    m = @rc_defaults
    keys.each do |k|
      #puts "  k=#{k} m=#{m.inspect}"
      m = m[k] if m
    end
    m
  end

  def initialize url
    @options = {
      :dbi_driver => nil,
      :host       => nil,
      :user       => nil,
      :pass       => nil,
      :database   => nil,
      :table      => nil,
    }

    @rc_defaults = {}
    if File.exist? CREDENTIALS_RC_FILE
      @rc_defaults.merge!(YAML.load_file(CREDENTIALS_RC_FILE))
    end

    @url = url
    schema, rest = url.split '://', 2

    # expect 'driver' name, eg: pg
    driver, host, database_name, table = rest.split '/', 4

    if driver =~ /@/
      user_pass, driver = driver.split '@', 2
      user, pass = nil, nil
      if user_pass =~ /:/
        user, pass = user_pass.split ':', 2
        @options[:user] = user
        @options[:pass] = pass
      end
      @options[:dbi_driver] = driver
    end

    @options[:dbi_driver] = driver
    @options[:database]   = database_name
    @options[:host]       = host
    @options[:table]      = table

    @options[:user] ||= lookup_rc_default @options[:host], @options[:database], "user"
    @options[:pass] ||= lookup_rc_default @options[:host], @options[:database], "pass"

    #puts "OPTIONS: #{@options.inspect}"

    require DB_MODULES[@options[:dbi_driver]][:require]
    driver_name = DB_MODULES[@options[:dbi_driver]][:name]

    @conn = DBI.connect("DBI:#{driver_name}:database=#{@options[:database]};host=#{@options[:host]}",@options[:user],@options[:pass]);

  end

  def open_for_reading
    if @options[:table]
      @columns = get_col_names @options[:table]
      @statement_handle = @conn.prepare "select * from #{@options[:table]}"
      @statement_handle.execute
    else
      @columns = ['NAME','ROWS']
      @rows = @conn.tables
    end
  end

  # TODO: implement insertion/append and truncation
#  def open_for_writing
#    close_statement_handle
#    @columns = get_col_names @options[:table]
#    sql_stmt = sprintf("INSERT INTO #{@options[:table]} VALUES (%s)", get_col_names.map {'?'}.join(","))
#    puts "sql_stmt: #{sql_stmt}"
#    @statement_handle = @conn.prepare sql_stmt
#  end

  def columns
    @columns
  end

  def get_col_names table
    sth = @conn.prepare "SELECT * FROM #{table} where 1=0"
    sth.execute
    col_names = sth.column_names
    sth.finish
    col_names
  end

  def next_record
    return @statement_handle.fetch if @statement_handle
    if @rows && !@rows.empty?
      table = @rows.shift
      sth = @conn.prepare("SELECT COUNT('x') from #{table}")
      sth.execute
      count = sth.fetch_array.first
      sth.finish
      return [table,count]
    end
    return nil
  end

  def rewind
    close_connection
    open_for_reading
  end

  def close 
    close_statement_handle
    close_connection
  end

  def close_connection
    if @conn
      @conn.close if @conn.respond_to? :close
      @conn = nil
    end
  end

  def close_statement_handle
    if @statement_handle
      @statement_handle.finish
      @statement_handle = nil
    end
  end

end

Abtab.register 'dbi', Abtab::Driver::DbiDriver
