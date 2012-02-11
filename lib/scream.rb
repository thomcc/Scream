require 'stringio'


module Scream

  ROOT_PATH = File.expand_path(File.dirname(__FILE__)) + '/scream'

  require ROOT_PATH + '/reader'

  class ScreamError < StandardError; end
  class SyntaxError < ScreamError; end

end

