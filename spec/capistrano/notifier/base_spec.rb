require 'spec_helper'
require 'capistrano/notifier'
require 'capistrano/notifier/base'

describe Capistrano::Notifier::Base do
  let(:configuration) { Capistrano::Configuration.new }
  subject { described_class.new configuration }

  it "defaults to the master branch" do
    subject.send(:branch).should == 'master'
  end

  context "when a branch is specified" do
    before :each do
      configuration.load { set :branch, 'foo' }
    end

    it "uses the specified branch" do
      subject.send(:branch).should == 'foo'
    end
  end
end
