# Rbprolog

The gem simulates logic processing functionality of prolog. It uses DSL style and only provides limited features now.

## Installation

Add this line to your application's Gemfile:

    gem 'rbprolog'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rbprolog

## Usage

1. Write a class to include Rbprolog, and describe the facts and rules

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

2. Instance the class to question

l = FriendLogic.new
l.likes?('p1', 's1') #=> true
l.friends?('p1', 'p4') #=> true

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
