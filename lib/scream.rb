require 'stringio'


module Scream

  ROOT_PATH = File.expand_path(File.dirname(__FILE__)) + '/scream'

  require ROOT_PATH + '/io'
  require ROOT_PATH + '/env'
  require ROOT_PATH + '/interpreter'
  class ScreamError < StandardError; end
  class TypeError < ScreamError; end
  class SyntaxError < ScreamError; end
  class LookupError < ScreamError; end


  def self.repl ip = $stdin, op = $stdout
    i = Interpreter.new
    op.puts "Scream version 0.1" if op
    while true
      begin
        op.print "> " if op
        d = Parser.read ip
        return if d == EOF_OBJECT
        r = i.eval d
        puts Writer.stringify r unless r == Scream::VOID
      rescue Exception => e
        op.puts "Error: #{e}"
      end
    end


  end

end

