require 'spec_helper'
require 'capistrano/notifier/statsd'

describe Capistrano::Notifier::StatsD do
  let(:configuration) { stub 'Capistrano::Configuraton' }

  describe ".get_options" do
    subject { described_class.get_options file, configuration }

    let(:file) { "" }

    before :each do
      configuration.stub(:exists?).with(:stage).and_return false
    end

    context "with no config file" do
      before :each do
        File.stub(:exists?).with(file).and_return(false)
      end

      it { subject[:host].should == "127.0.0.1" }
      it { subject[:port].should == "8125" }
    end

    context "with config file" do
      let(:yaml) { "host: 10.0.0.1\nport: '1234'" }

      before :each do
        File.stub(:exists?).with(file).and_return(true)
        YAML.stub(:load_file).with(file).and_return(YAML.load yaml)
      end

      it { subject[:host].should == "10.0.0.1" }
      it { subject[:port].should == "1234" }
    end

    context "with multistage config file" do
      let(:yaml) { "staging:\n  host: 10.0.0.1\n  port: '1234'" }

      before :each do
        File.stub(:exists?).with(file).and_return(true)
        YAML.stub(:load_file).with(file).and_return(YAML.load yaml)
        configuration.stub(:exists?).with(:stage).and_return true
        configuration.stub(:fetch).with(:stage).and_return :staging
      end

      it { subject[:host].should == "10.0.0.1" }
      it { subject[:port].should == "1234" }
    end
  end
end
