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

This gem comes with two different ERB templates that are used to generate the body of the email. To choose from each one of them, you can set the `format` option to either `:html` - for HTML emails - or `:text` - for plain text.

The following are the default values for the template options:

 - `format`: `:text`
 - `templates_path`: `"config/deploy/templates"`
 - `template`: `"mail.#{format}.erb"`. Note the dependency of this option on `format`.

The relationship between these variables might seem a bit complex but provides great flexibility. The logic used is as follows:

 - If the file exists in `"#{templates_path}/#{template}"`, then use that one. With no option set, this will default to `config/deploy/templates/mail.text.erb`.

 - If the file doesn't exist in the previous path, load `"#{template}"` from one of the gem's templates, either `mail.text.erb` or `mail.html.erb`. With no options set, this will default to `mail.text.erb` due to how the `template` option is generated. See above.

For those interested in creating customized templates, it is important to know that you can use any of the variables defined in capistrano by prefixing it with the `cap` method like below:

```rb
<%= cap.any_variable_defined_in_capistrano %>
```

The following is a list of some popular variables that don't require the use of the `cap.` prefix:

 - `application`: Name of the application.
 - `branch`: Name of the branch to be deployed.
 - `git_commit_prefix`: URL of the format `"#{git_prefix}/commit"`.
 - `git_compare_prefix`: URL of the format `"#{git_prefix}/compare"`.
 - `git_current_revision`: Commit for current revision.
 - `git_log`: Simplified log of commits in the `git_range`.
 - `git_prefix`: URL to the github repository. Depends on `giturl` or `github` variables.
 - `git_previous_revision`: Commit for previous revision.
 - `git_range`: Range of commits between previous and current revision. Example: xxx..yyy
 - `github`: URL path to the GitHub respository. Ex: 'MyCompany/project-name'.
 - `giturl`: Base URL to the repository.
 - `now`: Current time.
 - `stage`: Name of the stage from the capistrano multistage extension.
 - `user_name`: Name of the local git author.

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

You can define the pattern that will be used to define the key.
In the example the key will be 'test.deployment.example'

```rb
set :application, 'example'
set :stage,       'test'

set :notifier_statsd_options, {
  :pattern => "#{stage}.deployment.#{application}"
}
```

The `nc` ([Netcat](http://netcat.sourceforge.net/)) command is used to send messages to statsd and must be installed on the remote hosts. This is installed by default on most Unix machines.
