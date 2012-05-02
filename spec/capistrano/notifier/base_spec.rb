require 'spec_helper'
require 'capistrano/notifier'
require 'capistrano/notifier/base'

describe Capistrano::Notifier::Base do
  let(:configuration) { Capistrano::Configuration.new }
  subject { described_class.new configuration }

  it 'uses configured branch if not specified in configuration' do
    configuration.load { set :branch, 'foo' }
    subject.send(:branch).should == 'foo'
  end

  it 'uses master branch if not specified in configuration' do
    subject.send(:branch).should == 'master'
  end
end
