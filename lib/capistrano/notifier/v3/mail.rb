require 'capistrano/notifier'
require 'capistrano/notifier/v3/mail/helpers'
begin
  require 'action_mailer'
rescue LoadError
  require 'actionmailer'
end
include Capistrano::Notifier::V3::Mail::Helpers

namespace :deploy do
  namespace :notify do
    desc "Send a deployment notification via email."
    task :mail do
      run_locally do
        ActionMailer::Base.smtp_settings = notifier_smtp_settings
        ActionMailer::Base.mail({
          body: text,
          delivery_method: delivery_method,
          content_type: content_type_for_format(format),
          from: from,
          subject: subject,
          to: to
        }).deliver

        if delivery_method == :test
          puts ActionMailer::Base.deliveries
        end
      end
    end
  end
end

after "deploy:updated", "deploy:notify:mail"
