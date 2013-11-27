require 'capistrano/notifier'
require 'socket'

class Capistrano::Notifier::StatsD < Capistrano::Notifier::Base
  DEFAULTS = { :host => "127.0.0.1", :port => "8125", :with => :counter }

  def self.load_into(configuration)
    configuration.load do
      namespace :deploy do
        namespace :notify do
          desc 'Notify StatsD of deploy.'
          task :statsd do
            run Capistrano::Notifier::StatsD.new(configuration).command
          end
        end
      end

      after 'deploy:restart', 'deploy:notify:statsd'
    end
  end

  def command
    "echo -n #{packet.gsub('|', '\\|')} | nc -w 1 -u #{host} #{port}"
  end

  private

  def host
    options[:host]
  end

  def options
    if cap.respond_to? :notifier_statsd_options
      cap.notifier_statsd_options.reverse_merge DEFAULTS
    else
      DEFAULTS
    end
  end

  def packet
    "#{pattern}:#{with}"
  end

  def pattern
     options.fetch(:pattern){
       if stage
         "#{application}.#{stage}.deploy"
       else
         "#{application}.deploy"
       end
     }
  end

  def port
    options[:port]
  end

  def with
    case options[:with]
    when :counter then "1|c"
    when :gauge   then "1|g"
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Notifier::StatsD.load_into(Capistrano::Configuration.instance)
end
