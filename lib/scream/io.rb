
module Scream
  TOKEN_REGEXP = /\s*(,@|[('`,)]|"(?:[\\].|[^\\"])*"|;.*|[^\s('"`,;)]*)(.*)/
  EOF_OBJECT = :"#<eof-object>"
  QUOTES = { "'" => :quote, "`" => :quasiquote, ","  => :unquote, ",@" => :"unquote-splicing" }
  TOKENS = { true: "#t", false: "#f", sl_comment: ";", rp: ")", lp: "(", str_delim: '"', str_delim_esc: '\"' }

  class Lexer
    def initialize port = ''
      self.port = port
    end
    
    def match_next line
      m_data = TOKEN_REGEXP.match line
      m_data[1, 2] if m_data
    end
    
    def is_okay? token
      token and not(token.empty? or token[0] == TOKENS[:sl_comment])
    end

    def tok!
      begin
        @line = @port.gets if @line.empty?
        return EOF_OBJECT if @line.nil?
        token, @line = match_next @line
      end until is_okay? token
      token
    end

    include Enumerable
    def each 
      while (c = tok!) != EOF_OBJECT
        yield c
      end
    end

    def port= port
      @port, @line = port, ''
      @port = StringIO.new @port unless @port.respond_to? :gets
    end

  end

  module Parser

    def parse lexer
      tok = lexer.tok!
      tok == EOF_OBJECT ? tok : parsify(lexer, tok)
    end

    def read io
      parse Lexer.new(io)
    end

    def atom token
      if token == TOKENS[:true] then true    
      elsif token == TOKENS[:false] then false
      elsif token[0] == TOKENS[:str_delim]
        token[1..-2].gsub TOKENS[:str_delim_esc], TOKENS[:str_delim]
      else Integer token rescue Float token rescue token.to_sym
      end
    end
    
    def parsify lexer, token
      if token == TOKENS[:lp]
        l = []
        until (token = lexer.tok!) == TOKENS[:rp]
          l << parsify(lexer, token)
        end
        l
      elsif token == TOKENS[:rp] then raise Scream::SyntaxError, "unexpected rparen"
      elsif token == EOF_OBJECT  then raise Scream::SyntaxError, "unexpected EOF"
      elsif QUOTES[token] then [QUOTES[token], parse(lexer)]
      else atom token
      end
    end

  end

  module Writer
    def stringify x
      case x
      when true then "#t"
      when false then "#f"
      when String then x.inspect
      when Array then "(" << x.map {|i| stringify i }.join(' ') << ")"
      else x.to_s
      end
    end
  end

end
