require 'capistrano/notifier'
require 'capistrano/notifier/v3/statsd/helpers'
include Capistrano::Notifier::V3::StatsD::Helpers

namespace :deploy do
  namespace :notify do
    desc "Notify StatsD of deploy."
    task :statsd do
      on roles(:app), limit: 1 do |host|
        execute "echo -n #{packet.gsub('|', '\\|')} | nc -w 1 -u #{host} #{port}"
      end
    end
  end
end

after "deploy:updated", "deploy:notify:statsd"
