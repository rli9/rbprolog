require_relative "rbprolog/version"
require_relative 'rbprolog/context'
require_relative 'rbprolog/rule'
require_relative 'rbprolog/deduction'
require_relative 'rbprolog/var'

module Rbprolog
  def self.included(mod)
    class << mod
      attr_accessor :rules, :syms

      include ClassMethods
    end
  end

  def initialize(&block)
    instance_eval(&block) if block
  end

  def rules
    self.class.rules + (@rules || [])
  end

  module ClassMethods
    def keywords(*syms)
      raise if syms.any? {|sym| sym.to_s.end_with? '?'}

      self.syms ||= []
      self.syms.concat(syms)
    end

    def const_missing(sym)
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
        #FIXME only allow fact for now
        define_method(sym) do |*args|
          @rules ||= []
          @rules << Rule.new(sym, *args, [])
        end

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