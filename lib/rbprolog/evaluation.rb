module Rbprolog
  class Evaluation
    #FIXME the design is not good to have an empty array as args
    attr_accessor :args

    def initialize(expression)
      @args = []
      @expression = expression
    end

    def each_deduce(context, rules, id)
      print "#{"\t" * id.size}#{id.join('.')} ?(#{@args.join(', ')})"

      context.scope(self) do |scoped_args|
        puts " => ?(#{scoped_args.join(', ')})"

        kclass = Class.new
        kclass.send(:define_singleton_method, :const_missing) do |sym|
          context.deduce(sym)
        end

        yield context.binds if kclass.class_eval(@expression)
      end
    end
  end
end