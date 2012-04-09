module Capistrano
  module Notifier
    class Base
      def initialize(capistrano)
        @cap = capistrano
      end

      private

      def application
        cap.application.titleize
      end

      def branch
        cap.branch
      end

      def cap
        @cap
      end

      def current_revision
        cap.current_revision[0,7]
      end

      def git_log
        `git log #{git_range} --no-merges --format=format:"%h %s (%an)"`
      end

      def git_range
        "#{previous_revision}..#{current_revision}"
      end

      def previous_revision
        cap.previous_revision[0,7]
      end

      def now
        @now ||= Time.now
      end

      def stage
        cap.stage
      end

      def user
        user = ENV['DEPLOYER']
        user = `git config --get user.name`.strip if user.nil?
      end
    end
  end
end

# Band-aid for issue with Capistrano
# https://github.com/capistrano/capistrano/issues/168#issuecomment-4144687
Capistrano::Configuration::Namespaces::Namespace.class_eval do
  def capture(*args)
    parent.capture *args
  end
end
