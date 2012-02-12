require 'test/unit'
require_relative '../lib/scream'
include Scream 

class TestEnv < Test::Unit::TestCase
  def test_general
    env = Env.new [:foo], [32]
    
    assert_equal 32, env[:foo]
    
    env2 = Env.new [:bar], [false], env
    
    assert_equal false, env2[:bar]
    
    assert_raises(LookupError) { env2[:asdf] }
    assert_nothing_raised { env2[:foo] }

    assert_equal 32, env2[:foo]

    env3 = Env.new [], [], env2

    assert_equal false, env3[:bar]

    env4 = Env.new [:bar], ["one million"], env3

    assert_equal "one million", env4[:bar]

    assert_equal 32, env4[:foo]

    env4[:foo] = "not thirty-two anymore"

    assert_equal "not thirty-two anymore", env4[:foo]
    assert_equal "not thirty-two anymore", env[:foo]

    env4.define! :foo, "thirty-two again"

    assert_equal "thirty-two again", env4[:foo]
    assert_equal "not thirty-two anymore", env3[:foo]
  end


  def test_type
    assert_raises(Scream::TypeError) { Env.new 10, 20 }
    assert_raises(Scream::TypeError) { Env.new [:foo], [30, 40] }
    assert_raises(Scream::TypeError) { Env.new [:foo, :bar], [30] }
  end

end
