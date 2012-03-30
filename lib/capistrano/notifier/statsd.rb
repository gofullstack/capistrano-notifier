require 'yaml'
require 'capistrano'
require 'capistrano/notifier'

module Capistrano::Notifier::StatsD
  def self.load_into(configuration)
    configuration.set(:notifier, self)
    configuration.load do
      namespace :deploy do
        namespace :notify do
          desc 'Notify StatsD of deploy.'
          task :statsd do
            options = notifier.get_options(
              capture("cat #{current_path}/config/stats.yml"),
              configuration
            )
            run "echo #{application}.#{stage + '.' if stage}deploy:1\\|c | nc -w 1 -u #{options[:host]} #{options[:port]}"
          end
        end
      end

      after 'deploy', 'deploy:notify:statsd'
    end
  end

  def self.get_options(yaml = "", configuration)
    yaml = (YAML.load(yaml) || {}).symbolize_keys
    # Use the staging key if we have it
    if configuration.exists?(:stage)
      yaml = yaml[configuration.fetch(:stage).to_sym].symbolize_keys
    end
    yaml[:host] ||= '127.0.0.1'
    yaml[:port] ||= 8125
    yaml
  end
end

if Capistrano::Configuration.instance
  Capistrano::Notifier::StatsD.load_into(Capistrano::Configuration.instance)
end
