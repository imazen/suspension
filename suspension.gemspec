# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)


Gem::Specification.new do |s|
  s.name        = "suspension"
  s.version     = '1.1.1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jo Hund", "Nathanael Jones"]
  s.email       = ["jhund@clearcove.ca"]
  s.homepage    = "http://github.com/imazen/suspension"
  s.summary     = %q{Enabling cross-format merging through token suspension}
  s.description = ""
  s.rubyforge_project = "suspension"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]


  #s.add_runtime_dependency('diff_match_patch')
  s.add_runtime_dependency('diff_match_patch_native')


  # Test libraries
  s.add_development_dependency('rake')
  s.add_development_dependency('minitest')
  s.add_development_dependency('minitest-spec-expect')
end
