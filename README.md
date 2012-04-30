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
  :method => :test, # :smtp, :sendmail, or any other valid ActionMailer delivery method
  :from   => 'capistrano@domain.com',
  :to     => ['john@doe.com', 'jane@doe.com'],
  :github => 'MyCompany/project-name'
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

```rb
require 'capistrano/notifier/statsd'
```

A counter of 1 will be sent with the key `application.stage.deploy` if using multistage, or `application.deploy` if not.

If you want to specify a host:port other than
127.0.0.1:8125, you can do so like this:

```rb
set :notifier_statsd_options, {
  :host => "10.0.0.1",
  :port => "8125"
}
```
