module Abtab
  class Driver

    [:open_for_reading, :open_for_writing, :next_record, :write_record].each do |m|
      define_method(m) { raise "Error: #{m} not implemented in: #{self.class}" }
    end

    def import inp
      set_columns inp.columns
      while rec = inp.next_record
        break if rec.nil?
        write_record rec
      end
    end

    def url_parse url, options={}
      schema, rest = url.split '://', 2
      path, qs = rest.split '?', 2
      if qs
        qs.split(/[;&]/).each do |pair|
          k,v = pair.split '='
          k = URI.unescape k
          v = URI.unescape v
          options[k] = v
        end
      end
      return schema, path, options
    end
  end
end
