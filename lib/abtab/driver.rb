module Abtab
  class Driver
    def import inp
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
