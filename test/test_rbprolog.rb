require 'simplecov'
SimpleCov.start
require 'test/unit'
require 'rbprolog'

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

class TestRbprolog < Test::Unit::TestCase
  def test_fact_should_be_deduced
    l = FriendLogic.new

    assert_equal true, l.likes?('p1', 's1')
    assert_equal true, l.likes?('p1', 's2')

    assert_equal ['s1', 's2'], l.likes!('p1', Rbprolog::Var.new(:X)).map {|hash| hash[:X]}.uniq
  end

  def test_rule_should_be_deduced
    l = FriendLogic.new

    assert_equal true, l.friends?('p1', 'p2')
    assert_equal true, l.friends?('p1', 'p3')
    assert_equal true, l.friends?('p1', 'p4')
    assert_equal false, l.friends?('p1', 'p6')

    assert_equal ['p1', 'p2', 'p3', 'p4'], l.friends!('p1', Rbprolog::Var.new(:W)).map {|hash| hash[:W]}.uniq.sort
  end

  def test_logic_instance_should_allow_new_fact
    l = FriendLogic.new do
      likes 'p5', 's1'
    end

    assert_equal true, l.likes?('p5', 's1')
    assert_equal false, l.likes?('p5', 's2')
    assert_equal true, l.friends?('p5', 'p3')
    assert_equal false, l.friends?('p5', 'p2')
  end

  def test_logic_instance_should_allow_new_rule
    l = FriendLogic.new %q{
      friends 'p2', X, :if => likes?(X, 's1')
    }

    assert_equal true, l.friends?('p2', 'p3')
    assert_equal true, l.friends?('p2', 'p1')
  end

  def test_logic_instances_should_be_independent
    l1 = FriendLogic.new do
      likes 'p5', 's1'
    end

    l2 = FriendLogic.new do
      likes 'p5', 's2'
    end

    assert_equal true, l1.likes?('p5', 's1')
    assert_equal false, l1.likes?('p5', 's2')
    assert_equal true, l1.friends?('p5', 'p3')
    assert_equal false, l1.friends?('p5', 'p2')

    assert_equal false, l2.likes?('p5', 's1')
    assert_equal true, l2.likes?('p5', 's2')
    assert_equal false, l2.friends?('p5', 'p3')
    assert_equal true, l2.friends?('p5', 'p2')
  end
end