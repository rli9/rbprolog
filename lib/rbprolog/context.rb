module Rbprolog
  class Context
    attr_accessor :binds

    def initialize
      @scopes = []
      @binds = {}
    end

    def match?(v1, v2)
      v1 = deduce(v1)
      Var === v1 || Var === v2 || v1 == v2
    end

    def match!(v1, v2)
      if match?(v1, v2)
        @binds[v1.sym] = v2 if Var === v1 && !(Var === v2)
        true
      else
        false
      end
    end

    def [](sym)
      @binds[sym]
    end

    def []=(sym, value)
      @binds[sym] = value
    end

    def deduce(v)
      if Var === v
        unless @binds[v.sym]
          @scopes.last << v.sym
          @binds[v.sym] = Var.new(v.sym)
        end

        @binds[v.sym]
      else
        v
      end
    end

    def scope(predicate, &block)
      @scopes.push([])

      mirror = @binds.clone

      result = yield predicate.args.map {|arg| self.deduce(arg)}

      @scopes.pop.each {|bind| @binds.delete bind}
      @binds.merge!(mirror)

      result
    end
  end
end