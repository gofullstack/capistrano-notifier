require 'capistrano/notifier'
require 'net/http'
require 'uri'

class Capistrano::Notifier::NewRelic < Capistrano::Notifier::Base
  DEFAULTS = {}

  def self.load_into(configuration)
    configuration.load do
      namespace :deploy do
        namespace :notify do
          desc 'Notify New Relic of deploy.'
          task :new_relic do
            run Capistrano::Notifier::NewRelic.new(configuration).command
          end
        end
      end

      after 'deploy', 'deploy:notify:new_relic'
    end
  end

  def command
    post = Net::HTTP::Post.new(uri.request_uri)
    post.add_field 'x-api-key', options[:api_key]
    post.set_form_data form_data
    response_text = ""
    Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
      response = http.request(post)
      response_text = "#{response.code} #{response.message}"
    end
    "echo New Relic Deploy notification result: #{response_text}"
  end

  private

  def options
    if cap.respond_to? :notifier_new_relic_options
      cap.notifier_new_relic_options.reverse_merge DEFAULTS
    else
      DEFAULTS
    end
  end

  # Form data to be posted
  def form_data
    @form_data ||= {
      'deployment[app_name]'       => options[:app_name],
      'deployment[application_id]' => options[:application_id],
      'deployment[description]'    => ENV['NOTES'],
      'deployment[revision]'       => git_current_revision,
      'deployment[changelog]'      => git_log,
      'deployment[user]'           => user_name
    }
  end

  def uri
    @uri ||= URI('https://rpm.newrelic.com/deployments.xml')
  end
end

if Capistrano::Configuration.instance
  Capistrano::Notifier::NewRelic.load_into(Capistrano::Configuration.instance)
end
