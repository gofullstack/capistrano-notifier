# Capistrano Notifier [![Build Status](https://secure.travis-ci.org/cramerdev/capistrano-notifier.png)](https://secure.travis-ci.org/cramerdev/capistrano-notifier)

## Install

In your Gemfile:

```rb
gem 'capistrano-notifier'
```

and then `bundle install`

## Mail

### Configure

```rb
require 'capistrano/notifier/mail'

set :notifier_mail_options, {
  :method         => :test, # :smtp, :sendmail, or any other valid ActionMailer delivery method
  :from           => 'capistrano@domain.com',
  :to             => ['john@doe.com', 'jane@doe.com'],
  :github_project => 'MyCompany/project-name'
}

namespace :deploy do
  desc "Capistrano Notifier"
  task :notify do
    Capistrano::Notifier.new(self).perform
  end
end

after 'deploy', 'deploy:notify'
```

### Test

```sh
cap deploy:notify
```

## StatsD

To notify StatsD, `require 'capistrano/notifier/statsd'` in your deploy.rb. When deploying it will look for a config/stats.yml and load the host and port from there. It should use the stages if you're using multistage.

A counter of 1 will be sent with the key application.stage.deploy if using multistage or application.deploy if not. [Netcat](http://netcat.sourceforge.net/) must be installed on the remote machine.
