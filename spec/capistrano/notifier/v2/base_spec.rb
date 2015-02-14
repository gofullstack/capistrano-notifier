require 'spec_helper'
require 'capistrano/notifier'
require 'capistrano/notifier/v2/base'

describe Capistrano::Notifier::V2::Base do
  let(:configuration) { Capistrano::Configuration.new }
  subject { described_class.new configuration }

  describe "#branch" do
    it "defaults to master" do
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

  describe "#git_*" do
    context "on initial deploy" do
      it { subject.send(:git_log).should be_nil }
      it { subject.send(:git_range).should be_nil }
      it { subject.send(:git_current_revision).should be_nil }
      it { subject.send(:git_previous_revision).should be_nil }
    end
  end
end
