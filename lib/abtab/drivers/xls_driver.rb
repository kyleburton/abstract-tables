require 'spreadsheet'

class Abtab::Driver::XlsDriver < Abtab::Driver
  def initialize url
    @read_index = 1
    @read_worksheet_index = 0
    @write_index = 0
    @options = {}
    @options["client_encoding"] = "UTF-8"
    @schema, @file, @options = url_parse url, @options
  end

  def open_for_reading
    if !File.exists? @file
      raise "Error: can not open for reading, file does not exist: #{@file}"
    end

    book = Spreadsheet.open @file
    if @options["worksheet"]
      unless book.worksheets.detect { |ws| ws.name == @options["worksheet"] }
        raise "Error: specified worksheet (#{@options['worksheet']}) not found in workbook."
      end
      @read_fh = book.worksheet @options["worksheet"]
    else
      @read_fh = book.worksheet 0
    end

    header_line = @read_fh.row 0
    @columns = parse_line header_line
  end

  def parse_line l
    # For now, coerce everything string
    l.collect { |v| v.to_s }
  end

  def columns
    @columns
  end

  def next_record
    if @read_index >= @read_fh.count
      line = nil
    else
      line = parse_line @read_fh.row @read_index
      @read_index += 1
    end
    line
  end

  def close
    if @read_fh
      @read_fh = nil
    end
    if @write_fh
      @write_fh.write @file
      @write_fh = nil
    end
  end

  def open_for_writing
    @write_fh = Spreadsheet::Workbook.new
    @write_sheet = @write_fh.create_worksheet
    set_columns(@columns) if @columns && !@columns.empty
  end

  def write_record rec
    @write_sheet.row(@write_index).replace rec
    @write_index += 1
  end

  def set_columns cols
    @columns = cols
    write_record @columns
  end

end

Abtab.register 'xls', Abtab::Driver::XlsDriver
