require 'abtab/filter'

module Abtab
  class Filter::Grep < Abtab::Filter

    def filter_predicate= p
      @filter = p
    end

    def next_record
      rec = nil
      while rec = driver.next_record
        if @filter.call(rec)
          break
        else
          0
        end
      end
      return rec
    end

    def columns
      @driver.columns
    end

  end
end
