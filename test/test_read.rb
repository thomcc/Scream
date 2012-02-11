require 'test/unit'

require_relative '../lib/scream'
include Scream 
class TestLexer < Test::Unit::TestCase

  def test_types
    ["#t", "#f"].each { |b| assert_equal [b], lex(b) }
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
  include Parser
  def test_basic

    t1 = "(foo)"
    assert_equal [:foo], read(t1)
    t2 = "(()())"
   
    assert_equal [[], []], read(t2)

  end

  def test_pbalance
    t1 = "(((((((()()))))())()(()))((((())()()()(((())))))))"
    r1 = [[[[[[[[],[]]]]],[]],[],[[]]],[[[[[]],[],[],[],[[[[]]]]]]]]
    assert_equal r1, read(t1)
    assert_raise(Scream::SyntaxError, "all left parens") { read "(((" }
    assert_raise(Scream::SyntaxError, "all right parens") { read ")))" }
    assert_raise(Scream::SyntaxError, "left paren and empty list") { read "(()" }
    assert_raise(Scream::SyntaxError, "right paren and empty list") { read ")()" }
  end


  def test_primitives

    assert_equal true, read("#t")
    assert_equal false, read("#f")
    assert_equal 20, read("20")
    assert_equal 1.32, read("1.32")
    assert_equal :foo, read("foo")
    assert_equal 'foo " ', read('"foo \" "')
  end

  def test_quotes

    assert_equal [:unquote, :unquoted], read(",unquoted")
    assert_equal [:quote, :quoted], read("'quoted")
    assert_equal [:quasiquote, [:quasiquotedlist]], read("`(quasiquotedlist)")
    assert_equal [:"unquote-splicing", :unquotespliced], read(",@unquotespliced")
    t = "`(this ,is ,@(somewhat) of ',a more ,(complicated '(expression)))"
    r = [:quasiquote, [:this, [:unquote, :is], [:"unquote-splicing", [:somewhat]], :of, [:quote, [:unquote, :a]], :more, [:unquote, [:complicated, [:quote, [:expression]]]]]]
    assert_equal r, read(t)
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
    assert_equal ary, read(str)
  end


end
