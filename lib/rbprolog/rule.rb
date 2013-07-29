module Rbprolog

  #when fail at one predicate, the output values need be reset, and remove from the parent rule/s context
  class Rule
    attr_accessor :args, :sym

    def initialize(sym, *args, deductions)
      @sym = sym
      @args = args
      @deductions = [deductions].flatten
    end

    def each_deduce(rules, *args, id)
      print "#{"\t" * id.size}#{id.join('.')} #{@sym}(#{@args.map(&:to_s).join(', ')}).deduce(#{args.map(&:to_s).join(', ')})"

      context = Context.new
      context.scope(self) do
        if self.match!(context, args)
          puts " => #{@sym}(#{@args.map {|arg| context.deduce(arg).to_s}.join(', ')})" #{context.to_s} #{context.binds.inspect}"
          deduce_deductions(context, rules, *@deductions, id) do
            yield context.binds
          end
        else
          print "\n"
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

    private
    def deduce_deductions(context, rules, *deductions, id, &block)
      if deductions.empty?
        yield
      else
        predicate = deductions.shift
        if Deduction === predicate
          predicate.each_deduce(context, rules, id + [@deductions.size - deductions.size - 1]) do |hash|
            deduce_deductions(context, rules, *deductions, id, &block)
          end
        else
          @logic.send(:define_singleton_method, :const_missing) do |sym|
            context.binds[sym]
          end

          predicate.call && deduce_deductions(context, rules, *deductions, id, &block)
        end

      end
    end
  end
end