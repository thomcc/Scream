require 'test/unit'

require_relative '../lib/scream'
include Scream 
class TestLexer < Test::Unit::TestCase

  def test_types
    ["#t", "#f"].each { |b| assert_equal lex(b), [b] }
    10.times do
      r1 = rand.to_s
      r2 = rand(500000000).to_s
      assert_equal lex(r1), [r1]
      assert_equal lex(r2), [r2]
    end
  end

  def test_quotes
    t1 = "'a b 'cd e f"
    t2 = "`(a ,b ,@(c d e))"
    t3, t4, t5, t6 = "`", "'", ",", ",@"
    assert_equal lex(t1), ["'", "a", "b", "'", "cd", "e", "f"]
    assert_equal lex(t2), %w{` ( a , b ,@ ( c d e ) )}
    %w(` ' , ,@).each do |q|
      assert_equal lex(q), [q]
    end
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
    assert_equal lex(s), %w{( something ) ( some}

  end

  def test_strings 
    t1 = '("a b c d e f g")'
    t2 = '("a b \" c d e \" g \" \" \" \"\" ")'

    assert_equal lex(t1), ["(", '"a b c d e f g"', ")"]
    assert_equal lex(t2), ["(", '"a b \" c d e \" g \" \" \" \"\" "', ")"]

  end


  def test_basic
    t1 = '(a b c (d e f) g)'
    t2 = '(a b cd()()(())1020 "foobarbaz")'
    t3 = "("
    assert_equal lex(t1), %w{( a b c ( d e f ) g )}
    assert_equal lex(t2), %w{( a b cd ( ) ( ) ( ( ) ) 1020 "foobarbaz" )}
    assert_equal lex(t3), ["("]
  end

end

def lex s
  Lexer.new(s).to_a
end
