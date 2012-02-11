Gem::Specification.new do |s|
  s.name        = "scream"
  s.version     = "0.1.0"
  s.author      = "Thom Chiovoloni"
  s.email       = "chiovolonit@gmail.com"
  s.homepage    = ""
  s.summary     = %q(A Lisp in Ruby)
  s.description = %q(Terribly slow.  I'd like for it to be triple interpreted.)

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w(lib)
end
