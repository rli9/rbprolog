require_relative "rbprolog/version"
require_relative 'rbprolog/context'
require_relative 'rbprolog/rule'
require_relative 'rbprolog/deduction'
require_relative 'rbprolog/var'

module Rbprolog
  def self.included(mod)
    class << mod
      include ClassMethods
      attr_accessor :rules, :syms
    end
  end

  def initialize(string = nil, &block)
    if string || block
      class << self
        include Rbprolog
      end

      singletonclass = class << self; self; end

      singletonclass.keywords(*self.class.syms)
      singletonclass.class_eval(string) if string
      singletonclass.class_eval(&block) if block
    end
  end

  def rules
    singletonclass = class << self; self; end
    self.class.rules + (singletonclass.rules || [])
  end

  module ClassMethods
    def keywords(*syms)
      raise if syms.any? {|sym| sym.to_s.end_with? '?'}

      self.syms ||= []
      self.syms.concat(syms)
    end

    def const_missing(sym)
      puts sym
      Var.new(sym)
    end

    def method_missing(sym, *args)
      if self.syms.include? sym
        Hash === args.last ? rule(sym, *args) : rule(sym, *args, :if => [])
      elsif self.syms.include? sym.to_s.chomp('?').to_sym
        Deduction.new(self, sym.to_s.chomp('?').to_sym, *args)
      else
        super
      end
    end

    def rule(sym, *args, options)
      self.rules ||= []
      self.rules << Rule.new(sym, *args, options[:if])

      unless method_defined?(sym)
        define_method("#{sym}!") do |*args|
          Deduction.new(self, sym, *args)
        end

        define_method("#{sym}?") do |*args|
          self.send("#{sym}!", *args).any? {|hash| true}
        end
      end
    end
  end
end