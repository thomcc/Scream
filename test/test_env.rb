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

  end

  def test_varargs
    env = Env.new :foo, [30, 40, 50, 60]
    assert_equal [30, 40, 50, 60], env[:foo]
  end

  def test_mutation
    env = Env.new [:foo], [32]
    env2 = Env.new [], [], env
    env3 = Env.new [], [], env2

    assert_equal 32, env3[:foo]
    env3[:foo] = "not thirty-two anymore"
    assert_equal "not thirty-two anymore", env3[:foo]
    assert_equal "not thirty-two anymore", env[:foo]
    env3.define! :foo, "thirty-two again"
    assert_equal "thirty-two again", env3[:foo]
    assert_equal "not thirty-two anymore", env[:foo]
    env2.define! :boogiemen, "everywhere"
    assert_equal "everywhere", env3[:boogiemen]
    env3[:boogiemen] = "nowhere"    
    assert_equal "nowhere", env2[:boogiemen]



  end
  
  def test_binds
    env = Env.new [:zot!], [32]
    env2 = Env.new [:full_lexical], [false], env
    env3 = Env.new [], [], env2
    env4 = Env.new [:bar], ["one million"], env3


    assert env4.binds?(:zot!)

    env4.define! :quux, 9001
    assert env4.binds?(:quux)
    refute env3.binds?(:quux)
    env4.define! :full_lexical, "frobnicate"

    refute env2.binds?(:never_seen)
    
    assert env.binds?(:zot!)
    
    assert_equal false, env2[:full_lexical]

  end  



  def test_type
    assert_raises(Scream::TypeError) { Env.new 10, 20 }
    assert_raises(Scream::TypeError) { Env.new [:foo], [30, 40] }
    assert_raises(Scream::TypeError) { Env.new [:foo, :bar], [30] }
  end

end
