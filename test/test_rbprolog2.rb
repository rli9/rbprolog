require 'test_helper'
require 'test/unit'
require 'rbprolog'

class Logic
  include Rbprolog

  keywords :logic

  logic 'p1', X, X
  logic X, Y, Z, :if => logic?(X, Y, Z)
end

class ExclusionLogic
  include Rbprolog

  keywords :must, :can, :can_not, :must_not

  #%w(x y z).each {|t| must 'gen6', t}
  %w(x1 y1 z1).each {|t| must 'gen7', t}
  #must_not 'gen6', 'x2'
  #must 'gen6', %w(x y z)
  #must 'android', %w(x1 y1 z1)
  can_not X, Y, :if => [must?(U, Y), ->{'U != X'}]
  #can_not X, Y, :if => must_not?(X, Y)
  #can X, Y, :if => !can_not?(X, Y)
end

class TestRbprolog2 < Test::Unit::TestCase
  def test_logic_should_be_deduced
    l = Logic.new

    assert_equal true, l.logic?('p1', 's', 's')
    assert_equal [['p1', 's']], l.logic!(Rbprolog::Var.new(:X), Rbprolog::Var.new(:Y), 's').map {|hash| [hash[:X], hash[:Y]]}.uniq
  end
end

class TestExclusionLogic < Test::Unit::TestCase
  def test_exclusion_logic
    l = ExclusionLogic.new

    # assert_equal(l.must?('gen6', 'x'), true)
    # assert_equal(l.must?('gen6', 'w'), false)
    # assert_equal(l.must?('gen6', 'x2'), false)
    # assert_equal(l.can?('gen6', 'x'), true)
    # assert_equal(l.can?('gen7', 'x'), false)
    # assert_equal(l.can?('gen6', ['y']), true)
    # assert_equal(l.can?('gen7', ['y']), false)
    # assert_equal(l.can_not?('gen7', 'x'), true)
    # assert_equal(l.can_not?('gen6', 'x'), false)
    # assert_equal(l.can_not?('gen6', 'x1'), true)
    # assert_equal(l.can_not?('gen6', 'x2'), true)
#
    puts l.can_not!('gen6', Rbprolog::Var.new(:G)).map {|hash| hash[:G]}.inspect

    # assert_equal(l.can?('gen6', ['x2']), false)
    # assert_equal(l.can?('gen6', ['x9']), true)
#
    # assert_equal(l.can_not?('gen6', ['x2']), true)
    # assert_equal(l.can_not?('gen6', ['x9']), false)
  end
end