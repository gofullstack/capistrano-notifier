require 'capistrano/notifier'

begin
  require 'action_mailer'
rescue LoadError => e
  require 'actionmailer'
end

class Capistrano::Notifier::Mailer < ActionMailer::Base

  if ActionMailer::Base.respond_to?(:mail)
    def notice(text, from, subject, to, delivery_method)
      mail({
        :body => text,
        :delivery_method => delivery_method,
        :from => from,
        :subject => subject,
        :to => to
      })
    end
  else
    def notice(text, from, subject, to)
      body text
      from from
      subject subject
      recipients to
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
    notifier.deliver_notice(text, from, subject, to)
  end

  def perform_with_action_mailer(notifier = Capistrano::Notifier::Mailer)
    notifier.smtp_settings = smtp_settings
    notifier.notice(text, from, subject, to, notify_method).deliver
  end

  def body
    <<-BODY.gsub(/^ {6}/, '')
      #{user_name} deployed
      #{application.titleize} branch
      #{branch} to
      #{stage} on
      #{now.strftime("%m/%d/%Y")} at
      #{now.strftime("%I:%M %p %Z")}

      #{git_range}
      #{git_log}
    BODY
  end

  def from
    cap.notifier_mail_options[:from]
  end

  def github_commit_prefix
    "#{github_prefix}/commit"
  end

  def github_compare_prefix
    "#{github_prefix}/compare"
  end

  def github_prefix
    prefix = gitlab
    prefix ||= "https://github.com/#{github}"
    prefix
  end

  def github
    cap.notifier_mail_options[:github]
  end

  def gitlab
    cap.notifier_mail_options[:gitlab]
  end

  def html
    body.gsub(
      /([0-9a-f]{7})\.\.([0-9a-f]{7})/, "<a href=\"#{github_compare_prefix}/\\1...\\2\">\\1..\\2</a>"
    ).gsub(
      /^([0-9a-f]{7})/, "<a href=\"#{github_commit_prefix}/\\0\">\\0</a>"
    )
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

  def text
    body.gsub(/([0-9a-f]{7})\.\.([0-9a-f]{7})/, "#{github_compare_prefix}/\\1...\\2")
  end

  def to
    cap.notifier_mail_options[:to]
  end
end

if Capistrano::Configuration.instance
  Capistrano::Notifier::Mail.load_into(Capistrano::Configuration.instance)
end
