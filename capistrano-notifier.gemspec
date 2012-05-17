# -*- encoding: utf-8 -*-
require File.expand_path('../lib/capistrano/notifier/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Justin Campbell", "Nathan L Smith"]
  gem.email         = ["sysadmin@cramerdev.com"]
  gem.summary       = %q{Capistrano Notifier}
  gem.description   = %q{Simple notification hooks for Capistrano}
  gem.homepage      = "http://github.com/cramerdev/capistrano-notifier"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- spec/*`.split("\n")
  gem.name          = "capistrano-notifier"
  gem.require_paths = ["lib"]
  gem.version       = Capistrano::Notifier::VERSION

  case ENV['TEST_ENV']
  when 'rails-2.3'
    gem.add_dependency 'actionmailer', '~> 2.3.0'
  when 'rails-3.0'
    gem.add_dependency 'actionmailer', '~> 3.0.0'
  when 'rails-3.1'
    gem.add_dependency 'actionmailer', '~> 3.1.0'
  when 'rails-3.2'
    gem.add_dependency 'actionmailer', '~> 3.2.0'
  end

  gem.add_dependency 'activesupport'
  gem.add_dependency 'capistrano', '>= 2'

  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'timecop'
end
