require 'capistrano/notifier'

begin
  require 'action_mailer'
rescue LoadError
  require 'actionmailer'
end

class Capistrano::Notifier::Mailer < ActionMailer::Base

  def content_type_for_format(format)
    format == :html ? 'text/html' : 'text/plain'
  end

  if ActionMailer::Base.respond_to?(:mail)
    def notice(text, from, subject, to, delivery_method, format)
      mail({
        body: text,
        delivery_method: delivery_method,
        content_type: content_type_for_format(format),
        from: from,
        subject: subject,
        to: to
      })
    end
  else
    def notice(text, from, subject, to, format)
      body text
      content_type content_type_for_format(format)
      from from
      recipients to
      subject subject
    end
  end

end

class Capistrano::Notifier::Mail < Capistrano::Notifier::Base
  def self.load_into(configuration)
    configuration.load do
      namespace :deploy do
        namespace :notify do
          desc 'Send a deployment notification via email.'
          task :mail do
            Capistrano::Notifier::Mail.new(configuration).perform

            if configuration.notifier_mail_options[:method] == :test
              puts ActionMailer::Base.deliveries
            end
          end
        end
      end

      after 'deploy:restart', 'deploy:notify:mail'
    end
  end

  def perform
    if defined?(ActionMailer::Base) && ActionMailer::Base.respond_to?(:mail)
      perform_with_action_mailer
    else
      perform_with_legacy_action_mailer
    end
  end

  private

  def perform_with_legacy_action_mailer(notifier = Capistrano::Notifier::Mailer)
    notifier.delivery_method = notify_method
    notifier.deliver_notice(text, from, subject, to, format)
  end

  def perform_with_action_mailer(notifier = Capistrano::Notifier::Mailer)
    notifier.smtp_settings = smtp_settings
    notifier.notice(text, from, subject, to, notify_method, format).deliver
  end

  def email_template
    cap.notifier_mail_options[:template] || "mail.#{format.to_s}.erb"
  end

  def format
    cap.notifier_mail_options[:format] || :text
  end

  def from
    cap.notifier_mail_options[:from]
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
    cap.notifier_mail_options[:github]
  end

  def giturl
    cap.notifier_mail_options[:giturl]
  end

  def notify_method
    cap.notifier_mail_options[:method]
  end

  def smtp_settings
    cap.notifier_mail_options[:smtp_settings]
  end

  def subject
    "#{application.titleize} branch #{branch} deployed to #{stage}"
  end

  def template(template_name)
    config_file = "#{templates_path}/#{template_name}"

    unless File.exists?(config_file)
      config_file = File.join(File.dirname(__FILE__), "templates/#{template_name}")
    end

    ERB.new(File.read(config_file)).result(binding)
  end

  def templates_path
    cap.notifier_mail_options[:templates_path] || 'config/deploy/templates'
  end

  def text
    template(email_template)
  end

  def to
    cap.notifier_mail_options[:to]
  end
end

if Capistrano::Configuration.instance
  Capistrano::Notifier::Mail.load_into(Capistrano::Configuration.instance)
end
