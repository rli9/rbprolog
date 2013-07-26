module Rbprolog
  class Deduction
    include Enumerable
    attr_accessor :args, :sym

    def initialize(logic, sym, *args)
      @logic = logic
      @sym = sym

      @args = args
    end

    def each
      each_deduce(Context.new, @logic.class.rules, "", []) do |hash|
        yield hash
      end
    end

    def each_deduce(context, rules, tabs, id)
      print "#{tabs}#{id.join('.')} #{@sym}?(#{@args.map(&:to_s).join(', ')})"

      rules.select {|rule| rule.sym == @sym}.each_with_index do |rule, i|
        context.bind(self) do
          puts " => #{@sym}?(#{@args.map {|arg| context.deduce(arg).to_s}.join(', ')})" if i == 0 #{context.to_s} #{context.binds.inspect}" if i == 0

          rule.each_deduce(*@args.map {|arg| context.deduce(arg)}, tabs + "\t", id + [i]) do |hash|
            context.bind(self) do
              rule.args.each_with_index do |rule_arg, rule_arg_index|
                deduced_arg = context.deduce(@args[rule_arg_index])
                if Var === deduced_arg
                  context.binds[deduced_arg.sym] = Var === rule_arg ? hash[rule_arg.sym] : rule_arg
                end
              end

              #puts "#{tabs}#{context.to_s} #{context.binds.inspect})"
              yield context.binds
            end
          end
        end
      end
    end
  end
end