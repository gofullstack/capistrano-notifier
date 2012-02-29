# -*- encoding: utf-8 -*-
require File.expand_path('../lib/capistrano_notifier/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Justin Campbell"]
  gem.email         = ["justin@justincampbell.me"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- spec/*`.split("\n")
  gem.name          = "capistrano-notifier"
  gem.require_paths = ["lib"]
  gem.version       = CapistranoNotifier::VERSION

  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rspec'
end
