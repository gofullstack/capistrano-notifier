require 'socket'

class Capistrano::Notifier::StatsD < Capistrano::Notifier::Base
  DEFAULTS = { :host => "127.0.0.1", :port => "8125" }

  def self.load_into(configuration)
    configuration.load do
      namespace :deploy do
        namespace :notify do
          desc 'Notify StatsD of deploy.'
          task :statsd do
            Capistrano::Notifier::StatsD.new.perform
          end
        end
      end

      after 'deploy', 'deploy:notify:statsd'
    end
  end

  def perform
    socket.send packet, 0, host, port
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
    if stage
      "#{application}.#{stage}.deploy:1|c"
    else
      "#{application}.deploy:1|c"
    end
  end

  def port
    options[:port]
  end

  def socket
    @socket ||= UDPSocket.new
  end
end

if Capistrano::Configuration.instance
  Capistrano::Notifier::StatsD.load_into(Capistrano::Configuration.instance)
end
