module Capistrano
  module Notifier
    module V3
      module StatsD
        module Helpers
          def application
            fetch :application
          end

          def stage
            fetch :stage
          end

          def notifier_statsd_options
            @notifier_statsd_options ||= fetch :notifier_statsd_options
          end

          def defaults
            { host: "127.0.0.1", port: "8125", with: :counter }
          end

          def host
            options[:host]
          end

          def options
            if notifier_statsd_options
              notifier_statsd_options.reverse_merge defaults
            else
              defaults
            end
          end

          def packet
            "#{pattern}:#{send_with}"
          end

          def pattern
            options.fetch(:pattern){ default_pattern }
          end

          def default_pattern
            if stage
              "#{application}.#{stage}.deploy"
            else
              "#{application}.deploy"
            end
          end

          def port
            options[:port]
          end

          def send_with
            case options[:with]
            when :counter
              "1|c"
            when :gauge
              "1|g"
            end
          end
        end
      end
    end
  end
end
