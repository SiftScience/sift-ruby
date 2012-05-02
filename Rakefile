begin
  require "bundler/gem_tasks"
  Bundler::GemHelper.install_tasks
rescue LoadError => e
  warn "It is recommended that you use bundler during development: gem install bundler"
end

require "rspec/core/rake_task"

desc "Run tests"
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :test => :spec
