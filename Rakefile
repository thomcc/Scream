require 'rake'
require 'rake/testtask'

task :default => [:test_units]

desc "run basic tests"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
  t.warning = true
end

