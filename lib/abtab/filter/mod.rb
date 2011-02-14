require 'abtab/filter'

module Abtab
  class Filter::Mod < Abtab::Filter
    def initialize url
      @url = url
    end

    def mod_fn= p
      @mod_fn = p
    end

    def open_for_reading url=@url
      @url = url
      @driver = Abtab.read_handle @url
    end

    def next_record
      r = @driver_next_record
      if r.nil?
        nil
      else
        @mod_fn.call(r)
      end
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
