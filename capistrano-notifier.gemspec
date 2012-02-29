# -*- encoding: utf-8 -*-
require File.expand_path('../lib/capistrano_notifier/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Justin Campbell"]
  gem.email         = ["justin@justincampbell.me"]
  gem.description   = %q{Capistrano Notifier}
  gem.summary       = %q{Capistrano Notifier}
  gem.homepage      = "http://github.com/CramerDev/capistrano-notifier"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- spec/*`.split("\n")
  gem.name          = "capistrano-notifier"
  gem.require_paths = ["lib"]
  gem.version       = CapistranoNotifier::VERSION

  gem.add_dependency 'actionmailer'
  gem.add_dependency 'activesupport'

  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rspec'
end
