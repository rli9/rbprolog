module Rbprolog
  class Evaluation
    #FIXME the design is not good to have an empty array as args
    attr_accessor :args

    def initialize(expression)
      @args = []
      @expression = expression
    end

    def each_deduce(context, rules, id)
      print "#{"\t" * id.size}#{id.join('.')} #{@expression}?)"

      context.scope(self) do |scoped_args|
        kclass = Class.new
        kclass.send(:define_singleton_method, :const_missing) do |sym|
          context.deduce(Var.new(sym))
        end

        evaluation = kclass.class_eval(@expression)
        puts " => #{evaluation}"

        yield context.binds if evaluation
      end
    end
  end
end