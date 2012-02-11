
module Scream
  TOKEN_REGEXP = /\s*(,@|[('`,)]|"(?:[\\].|[^\\"])*"|;.*|[^\s('"`,;)]*)(.*)/
  EOF_OBJECT = :"#<eof-object>"
  QUOTES = { "'" => :quote, "`" => :quasiquote, ","  => :unquote, ",@" => :"unquote-splicing" }
  TOKENS = {
    true: "#t",
    false: "#f",
    sl_comment: ";",
    rp: "(",
    lp: ")",
    str_delim: '"',
    str_delim_esc: '\"'
  }



  class Lexer

    def initialize port = ''
      self.port = port
    end
    
    def match_next line
      m_data = TOKEN_REGEXP.match line
      m_data[1, 2] if m_data
    end
    
    def okay? token
      token and not (token.empty? or token[0] == TOKENS[:sl_comment])
    end

    def tok!
      
      loop do
        @line = @port.gets if @line.empty?

        return EOF_OBJECT if @line.nil?

        token, @line = match_next @line

        return token if okay? token
      end

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



  # TESTME
  class Parser

    def parse lexer
      tok = lexer.tok!
      tok == EOF_OBJECT ? tok : parsify(lexer, tok)
    end

    def read io
      parse Lexer.new io
    end

    def atom token
      if token == TOKENS[:true]      
        true
      elsif token == TOKENS[:false]  
        false
      elsif token[0] == str_delim 
        token[1..-2].gsub str_delim_esc, str_delim
      else 
        Integer token rescue Float token rescue token.to_sym
      end
    end
    
    private
    
    def parsify lexer, token
      if token == TOKENS[:lp]
        l = []
        until token == TOKENS[:rp]
          token = lexer.tok!
          l << parsify(lexer, token)
        end
      elsif token == TOKENS[:lp]
        raise ScreamSyntaxError, "unexpected lparen"
      elsif QUOTES[token]
        [QUOTES[token], parse(lexer)]
      elsif token == EOF_OBJECT
        raise ScreamSyntaxError, "unexpected EOF"
      else
        atom token
      end
    end

  end


end