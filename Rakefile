require 'rubygems'
require 'rake'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s| 
  s.name = "cucapp"
  s.version = "0.0.1"
  s.author = "Daniel Parnell"
  s.email = "daniel@automagic-software.com"
  s.homepage = "http://www.automagic-software.com/"
  s.platform = Gem::Platform::RUBY
  s.summary = "An interface between Cucumber and Cappuccino"
  s.files = FileList["{bin,lib,example}/**/*"].to_a
  s.files << 'cucapp.rb'
  s.files << 'Rakefile'
  s.autorequire = "cucapp"
  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = false
  s.extra_rdoc_files = ["README"]
  s.add_dependency("thin", ">= 0")
  s.add_dependency("nokogiri", ">= 0")
  s.add_dependency("json", ">= 0")
  s.add_dependency("launchy", ">= 0")
end
 
Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
end