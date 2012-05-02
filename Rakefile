require "bundler/gem_tasks"
Bundler::GemHelper.install_tasks

require "rubygems"
require "rspec/core/rake_task"

desc "Run unit tests"
RSpec::Core::RakeTask.new("spec:unit") do |t|
  t.pattern = "spec/unit/*_spec.rb"
  t.rspec_opts = ["--backtrace"]
end

desc "Run integration tests"
RSpec::Core::RakeTask.new("spec:integration") do |t|
  t.pattern = "spec/integration/*_spec.rb"
  t.rspec_opts = ["--backtrace"]
end
