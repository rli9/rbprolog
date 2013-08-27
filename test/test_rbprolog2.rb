require 'test_helper'
require 'test/unit'
require 'rbprolog'

class Logic
  include Rbprolog

  keywords :logic

  logic 'p1', X, X
  logic X, Y, Z, :if => logic?(X, Y, Z)
end

class TestRbprolog2 < Test::Unit::TestCase
  def test_logic_should_be_deduced
    l = Logic.new

    assert_equal true, l.logic?('p1', 's', 's')
    assert_equal [['p1', 's']], l.logic!(Rbprolog::Var.new(:X), Rbprolog::Var.new(:Y), 's').map {|hash| [hash[:X], hash[:Y]]}.uniq
  end
end