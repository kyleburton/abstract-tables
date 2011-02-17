require 'abtab/filter'

module Abtab
  class Filter::Cut < Abtab::Filter
    def set_cut_column_spec spec
      specs = spec.split ','
      @field_specs = []
      specs.each do |fset|
        if fset =~ /^(\d+)-(\d+)$/
          @field_specs << {:type => :range,
                          :from => $1,
                          :to   => $2}
        elsif fset =~ /^(\d+)-$/
          @field_specs << {:type => :open_from,
                          :from => $1}
        elsif fset =~ /^-(\d+)$/
          @field_specs << {:type => :open_to,
                          :to   => $1}
        else
          @field_specs << {:type => :single,
                          :field => fset}
        end
      end
      puts "Set field specs: #{@field_specs.inspect}"
    end

    def make_slice_fn
      if @field_specs.nil? || @field_specs.empty?
        raise "Error: you must set the columns before peforming a cut operation"
      end

      @fields = []
      @field_specs.each do |spec|
        if :range == spec[:type]
          Range.new($1.to_i - 1, $2.to_i - 1).each do |ii|
            @fields << ii
          end
        elsif :open_from == spec[:type]
          raise "Not supported at this time: open ranges"
        elsif :open_to == spec[:type]
          raise "Not supported at this time: open ranges"
        elsif :single == spec[:type]
          @fields << spec[:field].to_i - 1
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

    def next_record
      rec = @driver.next_record
      return nil if rec.nil?
      slice_fn.call(rec)
    end

    def columns
      slice_fn.call(@driver.columns)
    end

  end
end

