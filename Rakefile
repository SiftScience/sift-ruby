begin
  require "bundler/gem_tasks"
  Bundler::GemHelper.install_tasks
rescue LoadError => e
  warn "It is recommended that you use bundler during development: gem install bundler"
end

require "rspec/core/rake_task"
task :default => :spec

desc "Run tests"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "./spec/**/*_spec.rb"
end
