require 'fastercsv'
#require 'uri/escape'

class Abtab::Driver::CSVDriver < Abtab::Driver
  def initialize url
    @schema, rest = url.split '://', 2
    @file, qs = rest.split '?', 2
    @options = {
      "quote_char" => '"',
      "col_sep"    => ','
    }
    if qs
      qs.split(/[;&]/).each do |pair|
        k,v = pair.split '='
        k = URI::Escape.unescape k
        v = URI::Escape.unescape v
        @options[k] << v
      end
    end
    #puts "CSV: options=#{@options.inspect}"
  end

  def open_for_reading
    if !File.exists? @file
      raise "Error: can not open for reading, file does not exist: #{@file}"
    end

    @read_fh = File.open(@file,'r')
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
    @write_fh = File.open(@file,'w')
    set_columns(@columns) if @columns && !@columns.empty
  end

  def write_record rec
    @write_fh.puts rec.to_csv
  end

  def set_columns cols
    @columns = cols
    write_record @columns
  end

end

Abtab.register 'csv', Abtab::Driver::CSVDriver
