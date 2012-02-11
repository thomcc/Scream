require 'stringio'

class ScreamSyntaxError < Exception; end

TOKEN_REGEXP = /\s*(,@|[('`,)]|"(?:[\\].|[^\\"])*"|;.*|[^\s('"`,;)]*)(.*)/
EOF_OBJECT = :"#<eof-object>"
QUOTES = { "'" => :quote, "`" => :quasiquote, ","  => :unquote, ",@" => :"unquote-splicing" }

class Lexer
  def initialize port
    @port, @line = port, ''
  end

  def next_token
    loop do
      @line = @port.gets if @line == ''
      return EOF_OBJECT if @line.nil?
      m_data = TOKEN_REGEXP.match(@line)
      token, @line = m_data[1,2] if m_data
      return token if token and not (token == '' or token.start_with? ';')
    end
  end

  include Enumerable
  def each 
    while (c = next_token) != EOF_OBJECT
      yield c
    end
  end

  def port= port
    @port, @line = port, ''
  end
end

def atom token
  if token == "#t"      then true
  elsif token == "#f"   then false
  elsif token[0] == '"' then token[1..-1].gsub '\"', '"'
  else Integer(token) rescue Float(token) rescue token.to_sym
  end
end

def parse lexer
  read_ahead = lambda do |tok|
    if tok == '('
      l = []
      loop do
        tok = lexer.next_token
        return l if tok == ")"
        l << read_ahead[tok]
      end
    elsif tok == ')'        then raise ScreamSyntaxError, "unexpected )"
    elsif QUOTES[tok]       then [QUOTES[tok], parse(lexer)]
    elsif tok == EOF_OBJECT then raise ScreamSyntaxError, "unexpected EOF"
    else                         atom tok
    end
  end
  tok1 = lexer.next_token
  tok1 == EOF_OBJECT ? tok1 : read_ahead[tok1]
end

def read io
  parse Lexer.new(io)
end

def read_str s
  parse Lexer.new(StringIO.new s)
end


