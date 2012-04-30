require 'action_mailer'

class Capistrano::Notifier::Mail < Capistrano::Notifier::Base
  def perform
    mail = ActionMailer::Base.mail({
      :body => text,
      :delivery_method => notify_method,
      :from => from,
      :subject => subject,
      :to => to
    })

    mail.deliver

    puts ActionMailer::Base.deliveries if notify_method == :test
  end

  private

  def body
    <<-BODY.gsub(/^ {6}/, '')
      #{user_name} deployed
      #{application_name} branch
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
    "https://github.com/#{github}"
  end

  def github
    cap.notifier_mail_options[:github]
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

  def subject
    "#{application} branch #{branch} deployed to #{stage}"
  end

  def text
    body.gsub(/([0-9a-f]{7})\.\.([0-9a-f]{7})/, "#{github_compare_prefix}/\\1...\\2")
  end

  def to
    cap.notifier_mail_options[:to]
  end
end
