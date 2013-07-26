require 'test/unit'
require_relative '../lib/rbprolog'

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
  def test_friend_logic
    l = FriendLogic.new do
      likes 'p5', 's1'
    end

    assert_equal true, l.likes?('p1', 's1')
    assert_equal true, l.likes?('p1', 's2')
    assert_equal true, l.friends?('p1', 'p2')
    assert_equal true, l.friends?('p1', 'p3')
    assert_equal true, l.friends?('p1', 'p4')
    assert_equal false, l.friends?('p1', 'p6')
    assert_equal true, l.likes?('p5', 's1')

    assert_equal ['s1', 's2'], l.likes!('p1', Rbprolog::Var.new(:X)).map {|hash| hash[:X]}.uniq
    assert_equal ['p1', 'p2', 'p3', 'p4', 'p5'], l.friends!('p1', Rbprolog::Var.new(:W)).map {|hash| hash[:W]}.uniq.sort
  end
end