# Capistrano Notifier [![Build Status](https://secure.travis-ci.org/cramerdev/capistrano-notifier.png)](https://secure.travis-ci.org/cramerdev/capistrano-notifier)


## Install

In your Gemfile:

```rb
gem 'capistrano-notifier'
```

and then `bundle install`


## Mail

```rb
require 'capistrano/notifier/mail'

set :notifier_mail_options, {
  :method => :test, # :smtp, :sendmail, or any other valid ActionMailer delivery method
  :from   => 'capistrano@domain.com',
  :to     => ['john@doe.com', 'jane@doe.com'],
  :github => 'MyCompany/project-name'
}
```

If you specified `:method => test`, you can see the email that would be
generated in your console with `cap deploy:notify`.


## StatsD

```rb
require 'capistrano/notifier/statsd'
```

A counter of 1 will be sent with the key `application.stage.deploy` if using
multistage, or `application.deploy` if not. To use a gauge instead of a counter,
use `:with => :gauge`:

```rb
set :notifier_statsd_options, {
  :with => :gauge
}
```

If you want to specify a host:port other than
127.0.0.1:8125, you can do so like this:

```rb
set :notifier_statsd_options, {
  :host => "10.0.0.1",
  :port => "8125"
}
```
