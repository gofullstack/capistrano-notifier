require 'capistrano/version'

if defined?(Capistrano::VERSION) && Capistrano::VERSION.to_s.split('.').first.to_i >= 3
  require 'capistrano/notifier/v3/mail'
else
  require 'capistrano/notifier/v2/mail'
end
