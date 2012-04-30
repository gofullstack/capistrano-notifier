module Capistrano::Notifier::StatsD
  def self.load_into(configuration)
    configuration.set(:notifier, self)
    configuration.load do
      namespace :deploy do
        namespace :notify do
          desc 'Notify StatsD of deploy.'
          task :statsd do
            options = notifier.get_options(
              "#{current_path}/config/stats.yml",
              configuration
            )

            run "echo #{application}.#{stage + '.' if stage}deploy:1\\|c | nc -w 1 -u #{options[:host]} #{options[:port]}"
          end
        end
      end

      after 'deploy', 'deploy:notify:statsd'
    end
  end

  def self.get_options(file, configuration)
    defaults = { :host => "127.0.0.1", :port => "8125" }

    return defaults unless File.exists? file

    yaml = YAML.load_file(file).symbolize_keys

    # Use the staging key if we have it
    if configuration.exists?(:stage)
      stage = configuration.fetch(:stage).to_sym

      options = yaml[stage]
    else
      options = yaml
    end

    options.symbolize_keys!
    options.reverse_merge! defaults
  end
end

if Capistrano::Configuration.instance
  Capistrano::Notifier::StatsD.load_into(Capistrano::Configuration.instance)
end
