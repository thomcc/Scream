require 'test/unit'

require_relative '../lib/scream'
include Scream 
class TestInterpreter < Test::Unit::TestCase
  def test_defvv
    s1 = [:define, [:foo, :x, :y, :z], :doof]
    s2 = [:define, :foo, :doof]
    s3 = [:define, [:"print-fact", :n], 
           [:define, [:factorial, :n], [:if, :stuff, :do, :stuff]],
           [:printf, 'factorial of ~a is "~a"', :n, [:factorial, :n]]]
    r3 = [:"print-fact", 
          [:lambda, [:n],
            [:define, [:factorial, :n], [:if, :stuff, :do, :stuff]],
            [:printf, 'factorial of ~a is "~a"', :n, [:factorial, :n]]]]
    i = Interpreter.new

    assert_equal [:foo, :doof], i.def_var_val(s2)
    assert_equal [:foo, [:lambda, [:x, :y, :z], :doof]], i.def_var_val(s1)
    assert_equal r3, i.def_var_val(s3)
  end

  def test_basic
    i = Interpreter.new
    assert_equal 7, i.eval(7)
    assert_equal 10, i.eval([:+, 5, 5])
  end
  def test_quote
    i = Interpreter.new
    assert_equal [1, 2, 3], i.eval([:quote, [1, 2, 3]])
  end
  def test_lists
    i = Interpreter.new
    assert_equal 15, i.eval([:car, [:quote, [15, 16, 17, 18]]])
    assert_equal 16, i.eval([:car, [:cdr, [:quote, [15, 16, 17, 18]]]])
    assert_equal [40, 50], i.eval([:cons, 40, [:quote, [50]]])
    assert_equal [1, 2, 3, 4], i.eval([:cons, 1, [:cons, 2, [:cons, 3, [:cons, 4, [:quote, []]]]]])
    assert_equal true, i.eval([:null?, [:quote, []]])
  end
  def test_lambda_works
    i = Interpreter.new
    assert_equal 10, i.eval([[:lambda, [:x], [:+, :x, :x]], 5])
  end
  
  def test_math_builtin
    i = Interpreter.new
    assert_equal 20, i.eval([:+, 5, 3, 7, 6, -1])
    assert_equal 15, i.eval([:-, 20, 1, 1, 1, 1, 1])
    assert_equal 1000, i.eval([:*, 10, 5, 2, 10])
    assert_equal 20, i.eval([:/, 400, 10, 2])

    assert_equal false, i.eval([:"=", 3, 2])
    assert_equal true, i.eval([:"=", 3, 3])

  end

  def test_booleans
    i = Interpreter.new
    assert_equal false, i.eval([:not, true])
    assert_equal true, i.eval([:not, false])
  end

  def test_sequence_works
    i = Interpreter.new
    assert_equal 15, i.eval([:begin, 10, 11, 12, 13, 14, 15])
  end
  
  def test_if_works
    i = Interpreter.new
    assert_equal 30, i.eval([:if, true, 30, 40])
    assert_equal 40, i.eval([:if, false, 30, 40])
  end

  def test_define_works
    i = Interpreter.new
    i.eval([:define, :x, 5])
    assert_equal 5, i.eval(:x)
  end

  def test_interpret
    i = Interpreter.new
    assert_equal 5, i.interpret("(+ 2 3)")

  end
  def test_define_lambda_sugar_works
    i = Interpreter.new
    i.interpret "(define (plus2 x) (+ 2 x))"
    assert_equal 5, i.interpret("(plus2 3)")
  end
  def test_recursion_works
    i = Interpreter.new
    code =<<-'CODE'
    (define (factorial x)
      (if (= x 0) 
          1
          (* x (factorial (- x 1)))))
    CODE
    i.interpret code
    assert_equal 720, i.interpret("(factorial 6)")
  end
  def test_lexical_scope
    i = Interpreter.new
    code = <<-'CODE'
    ((lambda (x)
      (define (g y) (+ x y))
      ((lambda (x) (g 11)) 5)) 6)
    CODE
    assert_equal 17, i.interpret(code)
  end
end