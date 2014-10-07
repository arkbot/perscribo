# require 'rubygems'
# require 'bundler/setup'

require 'bundler/gem_tasks'
require 'cucumber/rake/task'
require 'guard/rake_task'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)
Cucumber::Rake::Task.new(:features)
Guard::RakeTask.new(:guard, '--no-interactions')

task default: :guard
