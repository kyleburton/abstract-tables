require 'abtab/filter'

module Abtab
  class Filter::Grep < Abtab::Filter
    def initialize url
      @url = url
    end

    def filter_predicate= p
      @filter = p
    end

    def open_for_reading url=@url
      @url = url
      @driver = Abtab.read_handle @url
    end

    def next_record
      rec = nil
      while rec = @driver.next_record
        if @filter.call(rec)
          break
        else
          #puts "rejecting: #{rec.inspect}"
          0
        end
      end
      return rec
    end

    def set_columns cols
      @driver.set_columns cols
    end

    def columns
      @driver.columns
    end

    def open_for_writing url=@url
      raise "Error: grep does not support writing."
      @driver = Abtab.write_handle @url
    end

    def write_record
      raise "Error: grep does not support writing."
    end

  end
end
