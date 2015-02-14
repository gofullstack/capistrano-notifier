module Capistrano
  module Notifier
    module V3
      module Mail
        module Helpers
          def application
            fetch :application
          end

          def branch
            fetch(:branch, "master")
          end

          def git_current_revision
            fetch :current_revision
          end

          def git_log
            return unless git_range

            `git log #{git_range} --no-merges --format=format:"%h %s (%an)"`
          end

          def git_previous_revision
            fetch :previous_revision
          end

          def git_range
            return unless git_previous_revision && git_current_revision

            "#{git_previous_revision}..#{git_current_revision}"
          end

          def now
            @now ||= Time.now
          end

          def stage
            fetch :stage
          end

          def user_name
            ENV['DEPLOYER'] || `git config --get user.name`.strip
          end

          def notifier_mail_options
            @notifier_mail_options ||= fetch :notifier_mail_options
          end

          def email_template
            notifier_mail_options[:template] || "mail.#{format.to_s}.erb"
          end

          def format
            notifier_mail_options[:format] || :text
          end

          def from
            notifier_mail_options[:from]
          end

          def git_commit_prefix
            "#{git_prefix}/commit"
          end

          def git_compare_prefix
            "#{git_prefix}/compare"
          end

          def git_prefix
            giturl ? giturl : "https://github.com/#{github}"
          end

          def github
            notifier_mail_options[:github]
          end

          def giturl
            notifier_mail_options[:giturl]
          end

          def delivery_method
            notifier_mail_options[:method]
          end

          def notifier_smtp_settings
            notifier_mail_options[:smtp_settings]
          end

          def subject
            notifier_mail_options[:subject] || "#{application.titleize} branch #{branch} deployed to #{stage}"
          end

          def template(template_name)
            config_file = "#{templates_path}/#{template_name}"

            unless File.exists?(config_file)
              config_file = File.join(File.dirname(__FILE__),"../../", "templates/#{template_name}")
            end

            ERB.new(File.read(config_file), nil, '-').result(binding)
          end

          def templates_path
            notifier_mail_options[:templates_path] || 'config/deploy/templates'
          end

          def text
            template(email_template)
          end

          def to
            notifier_mail_options[:to]
          end

          def content_type_for_format(format)
            format == :html ? 'text/html' : 'text/plain'
          end
        end
      end
    end
  end
end
