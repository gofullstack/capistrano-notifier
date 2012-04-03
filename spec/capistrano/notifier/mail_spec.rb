require "spec_helper"
require 'capistrano/notifier/mail'

describe Capistrano::Notifier::Mail do
  before do
    @configuration = Capistrano::Configuration.new
    @configuration.load do |configuration|
      set :notifier_mail_options, {
        :github_project => 'example/example',
        :method         => :sendmail,
        :from           => 'sender@example.com',
        :to             => 'example@example.com'
      }
    end
    @notifier = described_class.new(@configuration)
  end

  it { described_class.should be_a Class }

  specify 'github_project' do
    @notifier.send(:github_project).should === 'example/example'
  end

  specify 'notify_method' do
    @notifier.send(:notify_method).should === :sendmail
  end

  specify 'from' do
    @notifier.send(:from).should === 'sender@example.com'
  end

  specify 'to' do
    @notifier.send(:to).should === 'example@example.com'
  end
end
