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

      set :application, 'example'
      set :branch,      'master'
      set :stage,       'test'
      
      set :current_revision,  '1234567'
      set :previous_revision, '890abcd'
    end
  end

  it { subject.send(:github).should         == 'example/example' }
  it { subject.send(:notify_method).should  == :sendmail }
  it { subject.send(:from).should           == 'sender@example.com' }
  it { subject.send(:to).should             == 'example@example.com' }

  it "renders a plaintext email" do
    subject.send(:body).should == <<-BODY.gsub(/^ {6}/, '')
      Justin Campbell deployed
      Example branch
      master to
      test on
      01/01/2012 at
      12:00 AM EST

      890abcd..1234567

    BODY
  end
end
