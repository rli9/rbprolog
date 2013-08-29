require "rbprolog/version"
require 'rbprolog/context'
require 'rbprolog/rule'
require 'rbprolog/deduction'
require 'rbprolog/evaluation'
require 'rbprolog/var'

=begin rdoc
Simulate the prolog logic processing partially by using ruby based DSL

= Representations (Conventions)
[rule - class level]
  * name arg0, arg1, ..., {:if => [deduction0, deduction1, ...]}
  * name: defined in the keywords
  * arg: use const to present the variable, and non-const for value
  * deduction: see below

[fact - class level]
  * name: arg0, arg1, ...

[deduction - class level]
  * name? arg0, arg1, ...
  * return: true or false

[question - instance level]
  * name? arg0, arg1, ...

[enumerator - instance level]
  * name! arg0, arg1, ...
  * Deduce all possible answers

= Example
  class FriendLogic
    include Rbprolog

    keywords :likes, :friends

    likes 'p1', 's1'
    likes 'p1', 's2'
    likes 'p2', 's2'
    likes 'p3', 's1'
    likes 'p4', X

    friends 'p1', W, :if => likes?(W, 's2')
    friends X, Y, :if => [likes?(X, Z), likes?(Y, Z)]
  end

  l = FriendLogic.new
  l.likes?('p1', 's1') #=> true
  l.friends?('p1', 'p4') #=> true
=end

module Rbprolog
  def self.included(mod)
    class << mod
      include ClassMethods
      attr_accessor :rules, :syms
    end
  end

  #
  #Initialize the rbprolog instance, each instance can have its
  #own fact and rules. The definition can be passed in as string or block.
  #string is required when variable such as X is used.
  #  l = FriendLogic.new do
  #    likes 'p5', 's1'
  #  end
  #or
  #  l = FriendLogic.new %q{
  #    friends 'p2', X, :if => likes?(X, 's1')
  #  }
  #
  def initialize(string = nil, &block)
    if string || block
      self.extend(Rbprolog)

      self.singleton_class.keywords(*self.class.syms)
      self.singleton_class.class_eval(string) if string
      self.singleton_class.class_eval(&block) if block
    end
  end

  def rules
    self.class.rules + (self.singleton_class.rules || [])
  end

  module ClassMethods
    #Define the vocabulary of rules and facts
    def keywords(*syms)
      raise if syms.any? {|sym| sym.to_s.end_with? '?'}

      self.syms ||= []
      self.syms.concat(syms)
    end

    def const_missing(sym)
      Var.new(sym)
    end

    #Generate rule, fact and deduction based on conventions
    def method_missing(sym, *args)
      if self.syms.include? sym
        Hash === args.last ? rule(sym, *args) : rule(sym, *args, :if => [])
      elsif self.syms.include? sym.to_s.chomp('?').to_sym
        Deduction.new(sym.to_s.chomp('?').to_sym, *args)
      else
        super
      end
    end

    #Internal class method to install instance methods for question and enumerator
    def rule(sym, *args, options)
      self.rules ||= []
      self.rules << Rule.new(sym, *args, options[:if])

      unless method_defined?(sym)
        define_method("#{sym}!") do |*args|
          deduction = Deduction.new(sym, *args)

          deduction.extend(Enumerable)

          rules = self.rules
          deduction.define_singleton_method(:each) do |&block|
            each_deduce(Context.new, rules, []) do |hash|
              block.call hash
            end
          end

          deduction
        end

        define_method("#{sym}?") do |*args|
          self.send("#{sym}!", *args).any? {|hash| true}
        end
      end
    end
  end
end