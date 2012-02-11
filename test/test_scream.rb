require 'test/unit'
require 'stringio'
require_relative '../lib/scream'

class MyUnitTests < Test::Unit::TestCase

  def test_lexer_bool
    ["#t", "#f"].each {|b| assert_equal lex(b), [b]}
  end

  def test_lexer_quotes
    t1 = "'a b 'cd e f"
    t2 = "`(a ,b ,@(c d e))"
    t3, t4, t5, t6 = "`", "'", ",", ",@"
    assert_equal lex(t1), ["'", "a", "b", "'", "cd", "e", "f"]
    assert_equal lex(t2), %w{` ( a , b ,@ ( c d e ) )}
    ["`", "'", ",", "@"].each do |q|
      assert_equal lex(q), [q]
    end
  end
  def test_lexer_comments
    assert_equal lex(<<EOF), %w{( something ) ( some}
; nothing
; more nothing
; most nothing
(something) ; nothing
;;;;;;;; nothing
(some;)
EOF
  end
  def test_lexer_basic
    teststr1 = '(a b c (d e f) g)'
    teststr2 = '(a b cd()()(())1020 "foobarbaz")'
    teststr3 = '("a b c d e f g")'
    teststr4 = '("a b \" c d e \" g \" \" \" \"\" ")'

    assert_equal lex(teststr1), %w{( a b c ( d e f ) g )}

    assert_equal lex(teststr2), %w{( a b cd ( ) ( ) ( ( ) ) 1020 "foobarbaz" )}

    assert_equal lex(teststr3), ["(", '"a b c d e f g"', ")"]

    assert_equal lex(teststr4), ["(", '"a b \" c d e \" g \" \" \" \"\" "', ")"]
  end
end

def string_lexer s
  Lexer.new(StringIO.new s)
end

def lex s
  string_lexer(s).to_a
end