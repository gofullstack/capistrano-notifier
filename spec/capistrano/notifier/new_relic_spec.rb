require 'spec_helper'
require 'capistrano/notifier/new_relic'

describe Capistrano::Notifier::NewRelic do
  let(:configuration) { Capistrano::Configuration.new }
  let(:post) { mock(:post, :add_field     => nil,
                           :set_body_internal  => nil,
                           :response_body_permitted? => nil,
                           :[] => nil,
                           :[]= => nil,
                           :path => nil,
                           :exec => nil,
                           :set_form_data => nil) }
  subject { described_class.new configuration }

  before :each do
    configuration.load do
      set :application, 'example'
      set :notifier_new_relic_options, {
        :api_key        => 'ffffff',
        :application_id => 12345
      }
    end
    Net::HTTP::Post.stub(:new).and_return(post)
  end

  describe '#command' do
    it 'posts to the newrelic api'
  end
end
