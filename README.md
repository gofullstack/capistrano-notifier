# Capistrano Notifier [![Build Status](https://secure.travis-ci.org/cramerdev/capistrano-notifier.png)](https://secure.travis-ci.org/cramerdev/capistrano-notifier)


## Install

In your Gemfile:

```rb
gem 'capistrano-notifier'
```

and then `bundle install`

`cap` needs to be invoked with Bundler for the `require` statements
below to work properly. You can do so with either `bundle exec cap`, or
with `bundle install --binstubs` and making sure `bin` is high up in your
`$PATH`.`


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

If you specified `:method => :test`, you can see the email that would be
generated in your console with `cap deploy:notify:mail`.

If you specified `:method => :smtp`, you can specify `:smtp_settings`

For example:

```rb
set :notifier_mail_options, {
  :method => :smtp,
  :from   => 'capistrano@domain.com',
  :to     => ['john@doe.com', 'jane@doe.com'],
  :github => 'MyCompany/project-name',
  :smtp_settings => {
    address: "smtp.gmail.com",
    port: 587,
    domain: "gmail.com",
    authentication: "plain",
    enable_starttls_auto: true,
    user_name: MY_USERNAME,
    password: MY_PASSWORD
  }
}
```

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

The `nc` ([Netcat](http://netcat.sourceforge.net/)) command is used to send messages to statsd and must be installed on the remote hosts. This is installed by default on most Unix machines.
