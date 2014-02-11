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

### Templates

This gem comes with two different templates that are used to generate the body of the email. To choose from each one of them, you can set the `format` option to either `:html` - for HTML emails - or `:text` - for plain text.

The following are the default values for the template options:

 - `format`: `:text`
 - `templates_path`: `"config/deploy/templates"`
 - `template`: `"mail.#{format}.erb"`. Note the dependency of this option on `format`.

The relationship between these variables might seem a bit complex but provides great flexiility. The logic used is as follows:

 - If the file exists in `"#{templates_path}/#{template}"`, then use that one.
   - With no option set, this will default to `config/deploy/templates/mail.text.erb`.

 - If the file doesn't exist in the previous path, load `"#{template}"` from one of the gem's templates, either `mail.text.erb` or `mail.html.erb`.
   - With no options set, this will default to `mail.text.erb` due to how the `template` option is generated. See above.

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
