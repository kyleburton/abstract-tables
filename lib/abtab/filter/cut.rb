require 'abtab/filter'

module Abtab
  class Filter::Cut < Abtab::Filter
    def initialize url
      @url = url
    end

    def set_cut_column_spec spec
      specs = spec.split ','
      @field_sets = []
      specs.each do |fset|
        if fset =~ /^(\d+)-(\d+)$/
          @field_sets << {:type => :range,
                          :from => $1,
                          :to   => $2}
        elsif fset =~ /^(\d+)-$/
          @field_sets << {:type => :open_from,
                          :from => $1}
        elsif fset =~ /^-(\d+)$/
          @field_sets << {:type => :open_to,
                          :to   => $1}
        else
          @field_sets << {:type => :single,
                          :field => fset}
        end
      end
    end

    def make_slice_fn
      if ! @columns
        raise "Error: you must set the columns before peforming a cut operation"
      end

      @fields = []
      @field_specs.each do |spec|
        if :range == spec[:type]
          Range.new($1.to_i, $2.to_i).each do |ii|
            @fields << ii
          end
        elsif :open_from == spec[:type]
          raise "Not supported at this time: open ranges"
        elsif :open_to == spec[:type]
          raise "Not supported at this time: open ranges"
        elsif :single == spec[:type]
          @fields << spec[:field].to_i
        end
      end

      Proc.new do |r|
        res = []
        @fields.each do |ii|
          res << r[ii]
        end
        res
      end
    end

    def slice_fn
      @slice_fn ||= make_slice_fn
    end

    def open_for_reading url=@url
      @url = url
      @driver = Abtab.read_handle @url
    end

    def next_record
      rec = nil
      slice_fn.call(rec)
    end

    def set_columns cols
      @driver.set_columns cols
      @columns = cols
    end

    def columns
      slice_fn.call(@columns)
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

