require "action_mailer"
require "active_support"
require "capistrano_notifier/version"

Capistrano::Configuration::Namespaces::Namespace.class_eval do
  def capture(*args)
    parent.capture *args
  end
end

module Capistrano
  class Notifier
    def initialize(capistrano)
      @cap = capistrano
    end

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

    def application
      cap.application.titleize
    end

    def body
  <<-BODY
  #{user} deployed
  #{application} branch
  #{branch} to
  #{stage} on
  #{now.strftime("%m/%d/%Y")} at
  #{now.strftime("%I:%M %p %Z")}

  #{git_range}
  #{git_log}
  BODY
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

    def from
      cap.notify_from
    end

    def git_log
      `git log #{git_range} --no-merges --format=format:"%h %s (%an)"`
    end

    def git_range
      "#{previous_revision}..#{current_revision}"
    end

    def github_commit_prefix
      "#{github_prefix}/commit"
    end

    def github_compare_prefix
      "#{github_prefix}/compare"
    end

    def github_prefix
      "https://github.com/#{github_project}"
    end

    def github_project
      cap.notify_github_project
    end

    def html
      body.gsub(
        /([0-9a-f]{7})\.\.([0-9a-f]{7})/, "<a href=\"#{github_compare_prefix}/\\1...\\2\">\\1..\\2</a>"
      ).gsub(
        /^([0-9a-f]{7})/, "<a href=\"#{github_commit_prefix}/\\0\">\\0</a>"
      )
    end

    def previous_revision
      cap.previous_revision[0,7]
    end

    def notify_method
      cap.notify_method
    end

    def now
      @now ||= Time.new
    end

    def stage
      cap.stage
    end

    def subject
      "#{user} deployed #{application}@#{branch} to #{stage}"
    end

    def text
      body.gsub(/([0-9a-f]{7})\.\.([0-9a-f]{7})/, "#{github_compare_prefix}/\\1...\\2")
    end

    def to
      cap.notify_to
    end

    def user
      user = ENV['DEPLOYER']
      user = `git config --get user.name`.strip if user.nil?
    end
  end
end

