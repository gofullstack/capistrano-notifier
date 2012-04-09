require 'spec_helper'
require 'capistrano/notifier/mail'

describe Capistrano::Notifier::Mail do
  let(:configuration) { Capistrano::Configuration.new }
  subject { described_class.new configuration }

  before :each do
    configuration.load do |configuration|
      set :notifier_mail_options, {
        :github => 'example/example',
        :method => :sendmail,
        :from   => 'sender@example.com',
        :to     => 'example@example.com'
      }
    end
  end

  it { subject.send(:github).should         == 'example/example' }
  it { subject.send(:notify_method).should  == :sendmail }
  it { subject.send(:from).should           == 'sender@example.com' }
  it { subject.send(:to).should             == 'example@example.com' }
end
