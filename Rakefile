begin
  require 'bundler/gem_tasks'
rescue LoadError
  puts "Ruby >= 1.9 required for build tasks"
end

require 'rspec/core/rake_task'

task :default => :spec

desc "Run the test suite"
RSpec::Core::RakeTask.new

