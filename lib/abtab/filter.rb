require 'abtab/driver'
module Abtab
  class Filter
    attr_accessor :driver
    def initialize driver
      @driver = driver
    end
  end
end
