require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.pattern = "specs/**/*_spec.rb"
  t.verbose = true
end

task :default => ['test']
