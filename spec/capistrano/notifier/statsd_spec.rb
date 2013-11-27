require 'spec_helper'
require 'capistrano/notifier/statsd'

describe Capistrano::Notifier::StatsD do
  let(:configuration) { Capistrano::Configuration.new }
  subject { described_class.new configuration }

  before :each do
    configuration.load { set :application, 'example' }
  end

  it "sets defaults" do
    subject.send(:host).should == '127.0.0.1'
    subject.send(:port).should == '8125'
    subject.send(:with).should == '1|c'
  end

  it "creates a packet" do
    subject.send(:packet).should == "example.deploy:1|c"
  end

  it "creates a command" do
    subject.command.should ==
      "echo -n example.deploy:1\\|c | nc -w 1 -u 127.0.0.1 8125"
  end

  context "with a stage" do
    before :each do
      configuration.load do
        set :application, 'example'
        set :stage,       'test'
      end
    end

    it "creates a packet" do
      subject.send(:packet).should == "example.test.deploy:1|c"
    end
  end

  context "with statsd options" do
    before :each do
      configuration.load do
        set :notifier_statsd_options, {
          :host => '10.0.0.1',
          :port => '1234'
        }

        set :application, 'example'
      end
    end

    it "uses the options" do
      subject.send(:host).should == '10.0.0.1'
      subject.send(:port).should == '1234'
    end
  end

  context "with a gauge" do
    before :each do
      configuration.load do
        set :notifier_statsd_options, {
          :with => :gauge
        }

        set :application, 'example'
      end
    end

    it { subject.send(:with).should == "1|g" }
  end

  context "with an uppercase application" do
    before :each do
      configuration.load { set :application, 'Example' }

      it "lowercases the application" do
        subject.send(:packet).should == "example.deploy:1|c"
      end
    end
  end

  context "with a pattern" do
    before :each do
      configuration.load do
        set :application, 'example'
        set :stage,       'test'
        set :notifier_statsd_options, {
          :pattern => "#{stage}.deployment.#{application}"
        }
      end
    end

    it "creates a packet" do
      subject.send(:packet).should == "test.deployment.example:1|c"
    end

  end
end
