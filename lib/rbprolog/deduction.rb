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
      print "#{"\t" * id.size}#{id.join('.')} #{@sym}?(#{@args.join(', ')})"

      rules.select {|rule| rule.sym == @sym}.each_with_index do |rule, rule_index|
        context.scope(self) do |scoped_args|
          puts " => #{@sym}?(#{scoped_args.join(', ')})" if rule_index == 0

          rule.each_match(rules, *scoped_args, id + [rule_index]) do |hash|
            context.scope(self) do
              rule.args.each_with_index do |rule_arg, rule_arg_index|
                if Var === scoped_args[rule_arg_index]
                  context[scoped_args[rule_arg_index].sym] = Var === rule_arg ? hash[rule_arg.sym] : rule_arg
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