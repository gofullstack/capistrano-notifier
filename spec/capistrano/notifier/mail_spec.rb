require "spec_helper"
require 'capistrano/notifier/mail'

describe Capistrano::Notifier::Mail do
  it { described_class.should be_a Class }
end
