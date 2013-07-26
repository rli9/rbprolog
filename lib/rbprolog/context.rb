module Rbprolog
  class Context
    attr_accessor :binds

    def match?(v1, v2)
      v1 = deduce(v1)
      Var === v1 || Var === v2 || v1 == v2
    end

    def match!(v1, v2)
      if match?(v1, v2)
        if Var === v1 && !(Var === v2)
          @binds[v1.sym] = v2
        # elsif Var === v2 && !(Var === v1)
          # @binds[v2.sym] = v1
        end

        true
      else
        false
      end
    end

    def deduce(v)
      if Var === v
        unless @binds[v.sym]
          @stacks.last << v.sym
          @binds[v.sym] = Var.new(v.sym)
        end

        @binds[v.sym]
      else
        v
      end
    end

    def scope(predicate, &block)
      @stacks ||= []
      @stacks.push([])

      @binds ||= {}

      mirror = @binds.clone

      result = yield

      @stacks.pop.each {|bind| @binds.delete bind}
      @binds.merge!(mirror)

      result
    end
  end
end