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

      set :current_revision,  '12345670000000000000000000000000'
      set :previous_revision, '890abcd0000000000000000000000000'
    end

    subject.stub(:git_log).and_return <<-LOG.gsub /^ {6}/, ''
      1234567 This is the current commit (John Doe)
      890abcd This is the previous commit (John Doe)
    LOG
    subject.stub(:user_name).and_return "John Doe"
  end

  it 'delivers mail' do
    configuration.load do |configuration|
      set :notifier_mail_options, {
        :github => 'example/example',
        :method => :test,
        :from   => 'sender@example.com',
        :to     => 'example@example.com'
      }
    end

    subject.perform

    last_delivery = ActionMailer::Base.deliveries.last

    last_delivery.to.should include 'example@example.com'
    last_delivery.from.should include 'sender@example.com'

    ActionMailer::Base.deliveries.clear
  end
  
  it { subject.send(:github).should         == 'example/example' }
  it { subject.send(:notify_method).should  == :sendmail }
  it { subject.send(:from).should           == 'sender@example.com' }
  it { subject.send(:to).should             == 'example@example.com' }


  it 'delivers smtp mail' do
    configuration.load do |configuration|
      set :notifier_mail_options, {
        :github => 'example/example',
        :method => :test,
        :from   => 'sender@example.com',
        :to     => 'example@example.com',
        :smtp_settings => {
          :address => "smtp.gmail.com",
          :port => 587,
          :domain => "gmail.com",
          :authentication => "plain",
          :enable_starttls_auto => true,
          :user_name => "USERNAME",
          :password => "PASSWORD"
        }
      }
    end

    subject.perform

    subject.send(:smtp_settings).should == {
      address: "smtp.gmail.com",
      port: 587,
      domain: "gmail.com",
      authentication: "plain",
      enable_starttls_auto: true,
      user_name: "USERNAME",
      password: "PASSWORD"
    }

    last_delivery = ActionMailer::Base.deliveries.last

    last_delivery.to.should include 'example@example.com'
    last_delivery.from.should include 'sender@example.com'

    ActionMailer::Base.deliveries.clear
  end

  it "creates a subject" do
    subject.send(:subject).should == "Example branch master deployed to test"
  end

  it "renders a plaintext email" do
    subject.send(:body).should == <<-BODY.gsub(/^ {6}/, '')
      John Doe deployed
      Example branch
      master to
      test on
      01/01/2012 at
      12:00 AM #{Time.now.zone}

      890abcd..1234567
      1234567 This is the current commit (John Doe)
      890abcd This is the previous commit (John Doe)

    BODY
  end
end
