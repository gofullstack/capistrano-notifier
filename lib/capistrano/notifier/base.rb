class Capistrano::Notifier::Base
  def initialize(capistrano)
    @cap = capistrano
  end

  private

  def application
    cap.application
  end

  def branch
    cap.respond_to?(:branch) ? cap.branch : 'master'
  end

  def cap
    @cap
  end

  def git_current_revision
    cap.current_revision.try(:[], 0,7) if cap.respond_to?(:current_revision)
  end

  def git_log
    return unless git_range

    `git log #{git_range} --no-merges --format=format:"%h %s (%an)"`
  end

  def git_previous_revision
    cap.previous_revision.try(:[], 0,7) if cap.respond_to?(:previous_revision)
  end

  def git_range
    return unless git_previous_revision && git_current_revision

    "#{git_previous_revision.gsub("\r\n","")}...#{git_current_revision.gsub("\r\n","")}"
  end

  def now
    @now ||= Time.now
  end

  def stage
    cap.stage if cap.respond_to? :stage
  end

  def user_name
    user = ENV['DEPLOYER']
    user = `git config --get user.name`.strip if user.nil?
  end
end

# Band-aid for issue with Capistrano
# https://github.com/capistrano/capistrano/issues/168#issuecomment-4144687
Capistrano::Configuration::Namespaces::Namespace.class_eval do
  def capture(*args)
    parent.capture *args
  end
end
