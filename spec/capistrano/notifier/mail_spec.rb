require 'spec_helper'
require 'capistrano/notifier/mail'

describe Capistrano::Notifier::Mail do
  let(:configuration) { Capistrano::Configuration.new }
  subject { described_class.new configuration }

  before :each do
    configuration.load do |configuration|
      set :notifier_mail_options, {
        github: 'example/example',
        method: :sendmail,
        from:   'sender@example.com',
        to:     'example@example.com',
        format: :text
      }

      set :application, 'example'
      set :branch,      'master'
      set :stage,       'test'

      set :current_revision,  '12345670000000000000000000000000'
      set :previous_revision, '890abcd0000000000000000000000000'
    end

    subject.stub(:git_log).and_return <<-LOG.gsub(/^ {6}/, '')
      1234567 This is the current commit (John Doe)
      890abcd This is the previous commit (John Doe)
    LOG
    subject.stub(:user_name).and_return "John Doe"
  end

  it 'delivers mail' do
    configuration.load do |configuration|
      set :notifier_mail_options, {
        github: 'example/example',
        method: :test,
        from:   'sender@example.com',
        to:     'example@example.com'
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
        github: 'example/example',
        method: :test,
        from:   'sender@example.com',
        to:     'example@example.com',
        smtp_settings: {
          address: "smtp.gmail.com",
          port: 587,
          domain: "gmail.com",
          authentication: "plain",
          enable_starttls_auto: true,
          user_name: "USERNAME",
          password: "PASSWORD"
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

  it 'creates a subject' do
    subject.send(:subject).should == "Example branch master deployed to test"
  end

  context 'with a custom subject' do
    it 'uses a custom subject' do
      configuration.load do |configuration|
        set :notifier_mail_options, subject: 'test'
      end

      expect(subject.send(:subject)).to eq 'test'
    end
  end

  it 'should work with gitlab' do
    configuration.load do |configuration|
      set :notifier_mail_options, {
        giturl: 'https://my.gitlab.url/',
      }
    end

    subject.send(:git_prefix).should == 'https://my.gitlab.url/'
  end

  it 'should default to whatever was specified in giturl' do
    configuration.load do |configuration|
      set :notifier_mail_options, {
        giturl: 'https://my.gitlab.url/',
        github: 'example/example'
      }
    end

    subject.send(:git_prefix).should == 'https://my.gitlab.url/'
  end

  it 'renders a plaintext email' do
    subject.send(:text).should == <<-BODY.gsub(/^ {6}/, '')
      Deployer: John Doe
      Application: Example
      Branch: master
      Environment: test
      Time: 01/01/2012 at 12:00 AM #{Time.now.zone}

      Compare:
      https://github.com/example/example/compare/890abcd...1234567

      Commits:
      1234567 This is the current commit (John Doe)
      890abcd This is the previous commit (John Doe)

    BODY
  end

  context 'given the format is set to :html' do
    before do
      subject.stub(:format).and_return(:html)
    end

    it 'renders an html email' do
      subject.send(:text).should == <<-BODY.gsub(/^ {8}/, '')
        <!DOCTYPE html>
        <html>
          <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
          </head>
          <body leftmargin="0" marginwidth="0" topmargin="0" marginheight="0" offset="0">
            <h3>Details:</h3>
            <table>
              <tbody>
                <tr>
                  <td><strong>Deployer:</strong></td>
                  <td>John Doe</td>
                </tr>
                <tr>
                  <td><strong>Application:</strong></td>
                  <td>Example</td>
                </tr>
                <tr>
                  <td><strong>Branch:</strong></td>
                  <td>master</td>
                </tr>
                <tr>
                  <td><strong>Environment:</strong></td>
                  <td>test</td>
                </tr>
                <tr>
                  <td><strong>Time:</strong></td>
                  <td>01/01/2012 at 12:00 AM #{Time.now.zone}</td>
                </tr>
              </tbody>
            </table>

            <h3>Compare:</h3>
            <p>https://github.com/example/example/compare/890abcd...1234567</p>

            <h3>Commits:</h3>
              <p>1234567 This is the current commit (John Doe)</p>
              <p>890abcd This is the previous commit (John Doe)</p>

          </body>
        </html>
      BODY
    end
  end
end
