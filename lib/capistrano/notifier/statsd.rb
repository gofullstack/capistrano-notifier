require 'capistrano/version'
require 'socket'

if defined?(Capistrano::VERSION) && Capistrano::VERSION.to_s.split('.').first.to_i >= 3
  require 'capistrano/notifier/v3/statsd'
else
  require 'capistrano/notifier/v2/statsd'
end
