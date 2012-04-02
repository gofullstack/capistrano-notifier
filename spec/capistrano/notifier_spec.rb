require "spec_helper"
require 'capistrano/notifier'

describe Capistrano::Notifier do
  it { described_class.should be_a Module }
end
