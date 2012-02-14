require 'rational'
module Scream
  FORMS = {assign: :set, define: :define, lambda: :lambda, sequence: :begin, :if => :if, quote: :quote }
  VOID = :"#<void>"
  class Interpreter 
    BUILTINS = {
      :+        => lambda { |*as| as.inject :+ },
      :-        => lambda { |a,*as| a - as.inject(:+) },
      :*        => lambda { |*as| as.inject :* },
      :/        => lambda { |a,*as| Rational a, as.inject(:*) },
      :not      => lambda { |x| not x },
      :"="      => lambda { |a,b| a == b },
      :modulo   => lambda { |a,b| a % b },
      :quotient => lambda { |a,b| a.to_i / b.to_i },
      :expt     => lambda { |a,b| a ** b },
      # data structures
      :car      => lambda { |(fst,*_)| fst },
      :cdr      => lambda { |(_,*rst)| rst },
      :cons     => lambda { |fst,rst| [fst, *rst] },
      :null?    => lambda { |a| a.nil? or a == [] },
      :hash     => lambda { || {} },
      :get      => lambda { |h,k| h[k] },
      :put      => lambda { |h,k,v| h[k] = v },
      # ffi
      :new      => lambda { |c| Object.const_get c },
      :"."      => lambda { |c,*as| c.send *as },
      :reval    => lambda { |s| Kernel.eval s }

    }
    def initialize os=nil
      @out = os || $stdout
      @top_level = create_top_level
    end
    
    def create_top_level
      ks, vs = [], []
      BUILTINS.each {|k,v| ks.push(k); vs.push(v) }
      Env.new ks, vs
    end
    
    def eval_sequence((fst, *rst), env)
      fst_val = eval fst, env
      rst.nil? ? fst_val : eval_sequence(rst, env)
    end
    
    def def_var_val exp
      # either (define var val) or (define (var args) val) 
      # second is sugar for (define var (lambda (args) val))
      exp[1].is_a?(Symbol) ? [exp[1], exp[2]] : [exp[1][0], [FORMS[:lambda], exp[1][1..-1], *exp[2..-1]]]
    end
    
    def eval_def exp, env
      var, val = def_var_val exp
      env.define! var, eval(val, env)
    end
    
    def eval_if((_, pred, cons, alt), env)
      eval(pred, env) == true ? cons : alt
    end

    def eval exp, env = @top_level
      loop do
        return env[exp] if exp.is_a? Symbol
        return exp unless exp.is_a? Array
        case exp[0]
        when FORMS[:quote]    then return exp[1]
        when FORMS[:if]       then exp = eval_if exp, env
        when FORMS[:assign]   then env[exp[1]] = eval exp[2], env; return Scream::VOID
        when FORMS[:define]   then eval_def exp, env; return Scream::VOID
        when :debug           then puts env.pretty; return Scream::VOID
        when FORMS[:lambda]   then return Procedure.new exp[1], exp[2..-1], env
        when FORMS[:sequence] then exp = exp[1..-1].map {|e| eval e, env }[-1]
        else 
          exps = exp.map { |e| eval e, env }
          p = exps.shift
          if p.is_a? Procedure 
            exp, env = [:begin, *p.body], Env.new(p.args, exps, p.env)
          else 
            return p.call(*exps)
          end
        end
      end
    end

    def interpret str
      l = Parser.read str 
      eval l
    end

  end
end
