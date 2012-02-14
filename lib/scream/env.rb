module Scream
  UNDEFINED = :"#<undefined>"
  
  class Env
    attr_accessor :outer
    def initialize params=[], args=[], outer=nil
      @outer, @table = outer, Hash.new(UNDEFINED)
      bind params, args
    end
    
    def top_level?
      @outer.nil?
    end

    def [](k)
      v = @table[k]
      if v == UNDEFINED
        raise LookupError.new(k) if @outer.nil?
        v = @outer[k]
      end
      v
    end
    
    def define! var, val
      @table[var] = val
    end

    def bind params, args
      if params.is_a? Symbol
        @table[params] = args
      elsif params.is_a? Array and args.is_a? Array
        raise TypeError unless params.length == args.length
        params.zip(args) {|k,v| @table[k] = v }
      else
        raise TypeError.new "params must be an array!"
      end
    end

    def binds? var
      begin
        self[var]
      rescue LookupError
        false
      else
        true
      end
    end
    
    def pretty n=0
      s = ["### Env frame #{n}:"]
      @table.each do |k, v|
        kstr = k
        case v
        when Proc then vstr = ("#<builtin-procedure:'#{k}'>")
        when Procedure then vstr = "#<closure:'#{k}'>"
        else vstr = Writer.stringify v
        end
        s.push "#{kstr}  => #{vstr}"
      end

      if @outer.nil?
        s[0] += "(top level)"
      else
        s.push *@outer.pretty(n+1) unless @outer.nil?
      end
      s
    end

    def []=(var, val)
      if binds?(var) && @table[var] == UNDEFINED
        @outer[var] = val
      else
        define! var, val
      end
    end
  end

  class Procedure
    attr_accessor :args, :body, :env
    def initialize args, body, env
      @args, @body, @env = args, body, env
    end
  end
end