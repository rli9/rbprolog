module Rbprolog
  class Var
    attr_accessor :sym

    def initialize(sym)
      @sym = sym
    end

    def to_s; @sym.to_s; end

    def ==(other)
      true
    end
  end
end