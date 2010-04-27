require 'cucumber'
require 'cucumber/rake/task'
require 'rake/clean'

CLEAN.include "**/*\#", "**/*\.aux", "**/*\.rid", "log/**/*.log", "log/**/*.yml", "log/**/*.html", "log/**/*.txt", "log/**/*.xml"

CLOBBER.include "log"

desc 'Cucumber meets Cappuccino'

task :test => 'cukes:pass'

namespace :cukes do

  Cucumber::Rake::Task.new(:pass, 'run passing Cappuccino/Cucumber features') do |t|

    t.cucumber_opts = [
                       "-t ~@restart",
                       "-t ~@failz",
                       "--format progress -o log/cukes/pass/cucumber.log",
                       "--format html     -o log/cukes/pass/index.html",
                       "--format junit    -o log/cukes/pass/",
                       "--format pretty"]
  end

  desc 'should pass if the application is running on localhost'

  task :localhost => :restart

  Cucumber::Rake::Task.new(:restart, 'should pass if the application is running on localhost') do |t|

    t.cucumber_opts = [
                       "-t @restart",
                       "-t ~@failz",
                       "--format progress -o log/cukes/restart/cucumber.log",
                       "--format html     -o log/cukes/restart/index.html",
                       "--format junit    -o log/cukes/restart/",
                       "--format pretty"]
  end

  Cucumber::Rake::Task.new(:fail, 'Cappuccino/Cucumber features that do not pass yet') do |t|

    t.cucumber_opts = [
                       "-t @failz",
                       "--wip",
                       "--format progress -o log/cukes/fail/cucumber.log",
                       "--format html     -o log/cukes/fail/index.html",
                       "--format junit    -o log/cukes/fail/",
                       "--format pretty"]
  end

end
