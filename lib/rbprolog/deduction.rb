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
      each_deduce(Context.new, @logic.rules, []) do |hash|
        yield hash
      end
    end

    def each_deduce(context, rules, id)
      print "#{"\t" * id.size}#{id.join('.')} #{@sym}?(#{@args.map(&:to_s).join(', ')})"

      rules.select {|rule| rule.sym == @sym}.each_with_index do |rule, i|
        context.scope(self) do
          puts " => #{@sym}?(#{@args.map {|arg| context.deduce(arg).to_s}.join(', ')})" if i == 0

          rule.each_deduce(rules, *@args.map {|arg| context.deduce(arg)}, id + [i]) do |hash|
            context.scope(self) do
              rule.args.each_with_index do |rule_arg, rule_arg_index|
                deduced_arg = context.deduce(@args[rule_arg_index])
                if Var === deduced_arg
                  context.binds[deduced_arg.sym] = Var === rule_arg ? hash[rule_arg.sym] : rule_arg
                end
              end

              yield context.binds
            end
          end
        end
      end
    end
  end
end