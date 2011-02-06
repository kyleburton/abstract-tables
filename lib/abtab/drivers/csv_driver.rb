require 'fastercsv'
require 'uri'

class Abtab::Driver::CSVDriver < Abtab::Driver
  def initialize url
    @schema, @file, @options = url_parse url
  end

  def open_for_reading
    if @file == '/dev/stdin'
      @read_fh = $stdin
    else
      if !File.exists? @file
        raise "Error: can not open for reading, file does not exist: #{@file}"
      end
      @read_fh = File.open(@file,'r')
    end

    header_line = @read_fh.readline
    header_line.chomp!
    @columns = FasterCSV.parse(header_line, :quote_char => @options["quote_char"], :col_sep => @options["col_sep"]).first
  end

  def columns
    @columns
  end

  def next_record
    return nil if @read_fh.eof?
    line = @read_fh.readline
    line.chomp!
    FasterCSV.parse(line, :quote_char => @options["quote_char"], :col_sep => @options["col_sep"]).first
  end

  def close
    if @read_fh
      @read_fh.close
      @read_fh = nil
    end
  end

  def open_for_writing
    # NB: truncates the output file
    if @file == '/dev/stdout'
      @write_fn = $stdout
    else
      @write_fh = File.open(@file,'w')
    end
    set_columns(@columns) if @columns && !@columns.empty
  end

  def write_record rec
    line = rec.to_csv(:quote_char => @options["quote_char"], :col_sep => @options["col_sep"])
    @write_fh.puts line
  end

  def set_columns cols
    @columns = cols
    write_record @columns
  end

end

Abtab.register 'csv', Abtab::Driver::CSVDriver
