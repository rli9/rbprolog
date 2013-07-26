module Rbprolog

  #when fail at one predicate, the output values need be reset, and remove from the parent rule/s context
  class Rule
    attr_accessor :args, :sym

    def initialize(logic, sym, *args, predicates)
      @logic = logic
      @sym = sym
      @args = args
      @predicates = [predicates].flatten
    end

    def each_deduce(*args, tabs, id)
      print "#{tabs}#{id.join('.')} #{@sym}(#{@args.map(&:to_s).join(', ')}).deduce(#{args.map(&:to_s).join(', ')})"

      context = Context.new
      context.bind(self) do
        if self.match!(context, args)
          puts " => #{@sym}(#{@args.map {|arg| context.deduce(arg).to_s}.join(', ')})" #{context.to_s} #{context.binds.inspect}"
          deduce_predicates(context, *@predicates, tabs, id) do
            yield context.binds
          end
        else
          print "\n"
        end
      end
    end

    def deduce_predicates(context, *predicates, tabs, id, &block)
      if predicates.empty?
        yield
      else
        predicate = predicates.shift
        if Deduction === predicate
          predicate.each_deduce(context, @logic.rules, tabs + "\t", id + [@predicates.size - predicates.size - 1]) do |hash|
            deduce_predicates(context, *predicates, tabs, id, &block)
          end
        else
          @logic.send(:define_singleton_method, :const_missing) do |sym|
            context.binds[sym]
          end

          predicate.call && deduce_predicates(context, *predicates, tabs, id, &block)
        end

      end
    end

    def match?(context, args)
      @args.size == args.size && @args.zip(args).all? {|v1, v2| context.match?(v1, v2)}
    end

    def match!(context, args)
      match = match?(context, args)
      @args.zip(args).each {|v1, v2| context.match!(v1, v2)} if match
      match
    end
  end
end