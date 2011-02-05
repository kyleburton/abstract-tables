module Abtab
  class Driver
    def import inp
      while rec = inp.next_record
        break if rec.nil?
        write_record rec
      end
    end
  end
end
