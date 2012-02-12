module Scream
  UNDEFINED = :"#<undefined>"
  VOID = :"#<void>"
  
  class Env
    attr_accessor :outer
    def initialize params=[], args=[], outer=nil
      @outer = outer
      @table = Hash.new UNDEFINED
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

    def []=(var, val)
      if binds?(var) && @table[var] == UNDEFINED
        @outer[var] = val
      else
        define! var, val
      end
    end
  end




  


end