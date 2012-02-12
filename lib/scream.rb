require 'stringio'


module Scream

  ROOT_PATH = File.expand_path(File.dirname(__FILE__)) + '/scream'

  require ROOT_PATH + '/io'
  require ROOT_PATH + '/lang'

  class ScreamError < StandardError; end
  class TypeError < ScreamError; end
  class SyntaxError < ScreamError; end
  class LookupError < ScreamError; end

end

