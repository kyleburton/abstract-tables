
class Abtab::Driver::TabDriver < Abtab::Driver
  def initialize url
    @options = {}
    @options["col_sep"] = "\t"
    @schema, @file, @options = url_parse url, @options
  end

  def open_for_reading
    if !File.exists? @file
      raise "Error: can not open for reading, file does not exist: #{@file}"
    end

    @read_fh = File.open(@file,'r')
    header_line = @read_fh.readline
    @columns = parse_line header_line
  end

  def parse_line l
    l.chomp!
    r = l.split(@options["col_sep"]).map do |f|
      f.gsub! "\\t", "\t"
      f.gsub! "\\n", "\n"
      f.gsub! "\\r", "\r"
      f
    end
    r[0].chomp!
    r
  end

  def format_rec r
    r.map do |f|
      f.gsub! "\t", "\\t"
      f.gsub! "\n", "\\n"
      f.gsub! "\r", "\\r"
      f
    end.join(@options["col_sep"])
  end

  def columns
    @columns
  end

  def next_record
    return nil if @read_fh.eof?
    parse_line @read_fh.readline
  end

  def close
    if @read_fh
      @read_fh.close
      @read_fh = nil
    end
    if @write_fh
      @write_fh.close
      @write_fh = nil
    end
  end

  def open_for_writing 
    @write_fh = File.open(@file, 'w')
    set_columns(@columns) if @columns && !@columns.empty
  end

  def write_record rec
    @write_fh.puts format_rec(rec)
  end

  def set_columns cols
    @columns = cols
    write_record @columns
    
  end
end

Abtab.register 'tab', Abtab::Driver::TabDriver
