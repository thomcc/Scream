class Array # shorthand for array access
  def car; fst, *_ = self; fst; end
  def cdr; _, *rst = self; rst; end
  def caar; self.car.car; end
  def cadr; self.cdr.car; end
  def cdar; self.car.cdr; end
  def cddr; self.cdr.cdr; end
end
module Scream
  FORMS = {assign: :set, define: :define, lambda: :lambda, sequence: :begin, :if => :if, quote: :quote }
  BUILTINS = {
    :+    => lambda { |*as| as.inject :+ },
    :-    => lambda { |a,*as| a - as.inject(:+) },
    :*    => lambda { |*as| as.inject :* },
    :/    => lambda { |a,*as| a / as.inject(:*)},

    :car  => lambda { |(fst,*_)| fst },
    :cdr  => lambda { |(_,*rst)| rst },
    :cons => lambda { |fst,rst| [fst, *rst] }
  }
  class Interpreter
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
      exp[1].is_a?(Symbol) ? [exp[1], exp[2]] : [exp[1][0], [FORMS[:lambda], exp[1].cdr, *exp[2..-1]]]
    end
    
    def eval_def exp, env
      var, val = def_var_val exp
      env.define! var, eval(val, env)
    end
    
    def eval_if((_, pred, cons, alt), env)
      eval(pred, env) == true ? eval(cons, env) : eval(alt, env)
    end

    def eval exp, env = @top_level
      loop do
        return env[exp] if exp.is_a? Symbol
        return exp unless exp.is_a? Array
        case exp[0]
        when FORMS[:quote]    then return exp[1]
        when FORMS[:if]       then exp = eval_if exp, env
        when FORMS[:assign]   then env[exp[1]] = eval exp[2], env; return nil
        when FORMS[:define]   then eval_def exp, env; return nil
        when FORMS[:lambda]   then return Procedure.new exp.cadr, exp.cddr, env
        when FORMS[:sequence] then exp = exp[1..-1].map {|e| eval e, env }[-1]
        else 
          exps = exp.map { |e| eval e, env }
#          puts exps.inspect
          p = exps.shift
          if p.is_a? Procedure 
            exp, env = [:begin, *p.body], Env.new(p.args, exps, env)
          else 
            exp = p.call(*exps)
          end
        end
      end
    end
  end
end