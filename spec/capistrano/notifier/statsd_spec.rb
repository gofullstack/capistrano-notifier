require "spec_helper"
require 'capistrano/notifier/statsd'

describe Capistrano::Notifier::StatsD do
  it { described_class.should be_a Module }

  specify 'get_options, not multistage' do
    configuration = double('Capistrano::Configuraton')
    configuration.stub(:exists?).and_return false
    yaml =<<EOF
host: 10.0.0.1
port: 8125
EOF
    options = described_class.get_options(yaml, configuration)
    options[:host].should === '10.0.0.1'
    options[:port].should === 8125
  end

  specify 'get_options, multistage' do
    configuration = double('Capistrano::Configuraton')
    configuration.stub(:exists?).and_return true
    configuration.stub(:fetch).and_return 'staging'
    yaml =<<EOF
staging:
  host: 10.0.0.1
  port: 8125
EOF
    options = described_class.get_options(yaml, configuration)
    options[:host].should === '10.0.0.1'
    options[:port].should === 8125
  end

end
