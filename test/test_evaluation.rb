require 'test_helper'
require 'test/unit'
require 'rbprolog'

class EvaluationLogic
  include Rbprolog

  keywords :must, :can, :can_not, :must_not

  %w(a b c).each {|t| must 'win', t}
  must_not 'linux', 'd'
  must 'win', 'xp', 'e'

  can_not TC, :if => must_not?(TC)

  can_not X, TC, :if => [must?(U, TC), ->{'U != X'}]
  can_not X, TC, :if => must_not?(X, TC)

  can_not X, Y, TC, :if => [must?(U, V, TC), ->{'U != X || V != Y'}]
  can_not X, TC, :if => must_not?(X, Y, TC)

  #can X, Y, :if => !can_not?(X, Y)
end

class TestEvaluation < Test::Unit::TestCase
  def test_evaluation
    l = EvaluationLogic.new

    assert_equal true, l.must?('win', 'a')
    assert_equal true, l.can_not?('linux', 'd')
    assert_equal true, l.can_not?('linux', 'a')
    assert_equal true, l.can_not?('linux', 'b')
    assert_equal true, l.can_not?('linux', 'c')

    assert_equal(['a', 'b', 'c', 'd'], l.can_not!('linux', Rbprolog::Var.new(:G)).map {|hash| hash[:G]}.uniq.sort)
    assert_equal([], l.can_not!('win', Rbprolog::Var.new(:G)).map {|hash| hash[:G]}.uniq.sort)

    assert_equal true, l.must?('win', 'xp', 'e')
    assert_equal([], l.can_not!('win', 'xp', Rbprolog::Var.new(:G)).map {|hash| hash[:G]}.uniq.sort)
    assert_equal(['e'], l.can_not!('win', 'vista', Rbprolog::Var.new(:G)).map {|hash| hash[:G]}.uniq.sort)
  end
end