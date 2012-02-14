require 'test/unit'

require_relative '../lib/scream'
include Scream 
class TestLexer < Test::Unit::TestCase

  def test_types
    ["true", "false"].each { |b| assert_equal [b], lex(b) }
    10.times do
      r1 = rand.to_s
      r2 = rand(500000000).to_s
      assert_equal [r1], lex(r1)
      assert_equal [r2], lex(r2)
    end
  end

  def test_quotes
    t1 = "'a b 'cd e f"
    t2 = "`(a ,b ,@(c d e))"
    assert_equal ["'", "a", "b", "'", "cd", "e", "f"], lex(t1)
    assert_equal %w{` ( a , b ,@ ( c d e ) )}, lex(t2)
    %w(` ' , ,@).each do |q|
      assert_equal [q], lex(q)
    end
  end


  def test_portsetting 
    l = Lexer.new

    assert_equal Scream::EOF_OBJECT, l.tok!
    l.port = "()()"
    assert_equal '(', l.tok!
    assert_equal ')', l.tok!
    l.port = ")foo("
    assert_equal ')', l.tok!
    assert_equal 'foo', l.tok!
    assert_equal '(', l.tok!
    assert_equal Scream::EOF_OBJECT, l.tok!

  end

  def test_comments
    s = %q{           
          
      ; nothing
      ; more nothing
      ; still nothing
      (something) ;nothing
      ;;;;;;;;;;;;;;;;;;;;nothing         
      (some;thing)      

    }
    assert_equal %w{( something ) ( some}, lex(s)

  end

  def test_strings 
    t1 = '("a b c d e f g")'
    t2 = '("a b \" c d e \" g \" \" \" \"\" ")'

    assert_equal ["(", '"a b c d e f g"', ")"], lex(t1)
    assert_equal ["(", '"a b \" c d e \" g \" \" \" \"\" "', ")"], lex(t2)

  end


  def test_basic
    t1 = '(a b c (d e f) g)'
    t2 = '(a b cd()()(())1020 "foobarbaz")'
    t3 = "("
    assert_equal %w{( a b c ( d e f ) g )}, lex(t1)
    assert_equal %w{( a b cd ( ) ( ) ( ( ) ) 1020 "foobarbaz" )}, lex(t2)
    assert_equal %w{(}, lex(t3)
  end

end

def lex s
  Lexer.new(s).to_a
end

class TestParser < Test::Unit::TestCase

  def test_basic

    t1 = "(foo)"
    assert_equal [:foo], Parser.read(t1)
    t2 = "(()())"
   
    assert_equal [[], []], Parser.read(t2)

  end

  def test_pbalance
    t1 = "(((((((()()))))())()(()))((((())()()()(((())))))))"
    r1 = [[[[[[[[],[]]]]],[]],[],[[]]],[[[[[]],[],[],[],[[[[]]]]]]]]
    assert_equal r1, Parser.read(t1)
    assert_raise(Scream::SyntaxError, "all lparens")   { Parser.read "(((" }
    assert_raise(Scream::SyntaxError, "all rparens")   { Parser.read ")))" }
    assert_raise(Scream::SyntaxError, "lparen and ()") { Parser.read "(()" }
    assert_raise(Scream::SyntaxError, "rparen and ()") { Parser.read ")()" }
  end


  def test_primitives

    assert_equal true,    Parser.read("true")
    assert_equal false,   Parser.read("false")
    assert_equal 20,      Parser.read("20")
    assert_equal 1.32,    Parser.read("1.32")
    assert_equal :foo,    Parser.read("foo")
    assert_equal 'foo "', Parser.read('"foo \""')
  end

  def test_quotes

    assert_equal [:unquote, :unquoted], Parser.read(",unquoted")
    assert_equal [:quote, :quoted], Parser.read("'quoted")
    assert_equal [:quasiquote, [:quasiquotedlist]], Parser.read("`(quasiquotedlist)")
    assert_equal [:"unquote-splicing", :unquotespliced], Parser.read(",@unquotespliced")
    t = "`(this ,is ,@(somewhat) of ',a more ,(complicated '(expression)))"
    r = [:quasiquote, [:this, [:unquote, :is], [:"unquote-splicing", [:somewhat]], :of, 
        [:quote, [:unquote, :a]], :more, [:unquote, [:complicated, [:quote, [:expression]]]]]]
    assert_equal r, Parser.read(t)
  end

  def test_misc
    str = %q{
(define (print-fact n)
  (define (factorial n) ; hey i'm a comment
    (if (= n 0) 1 ; do some stuff
        (* n (factorial (- n 1)))))
  (printf "factorial of ~a is \"~a\"" n (factorial n)))
; dicks.
}
    ary = [:define, [:"print-fact", :n], 
           [:define, [:factorial, :n], 
            [:if, [:"=", :n, 0], 1, 
             [:"*", :n, [:factorial, [:"-", :n, 1]]]]], 
           [:printf, 'factorial of ~a is "~a"', :n, [:factorial, :n]]]
    assert_equal ary, Parser.read(str)
  end
end

class TestWriter < Test::Unit::TestCase
  def test_basic
    assert_equal "(foo bar baz)", Writer.stringify([:foo, :bar, :baz])
    assert_equal "()", Writer.stringify([])
    assert_equal "20", Writer.stringify(20)
    assert_equal "(foo (bar) baz (((quux)) ()))", Writer.stringify([:foo, [:bar], :baz, [[[:quux]], []]])
  end

  def test_strings
    assert_equal '"foo"', Writer.stringify("foo")
    assert_equal '"foo \"bar\" baz"', Writer.stringify('foo "bar" baz')
  end


end
