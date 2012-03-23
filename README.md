# CapistranoNotifier [![Build Status](https://secure.travis-ci.org/cramerdev/capistrano-notifier.png)](https://secure.travis-ci.org/cramerdev/capistrano-notifier)

## Install

In your Gemfile:

```rb
gem 'capistrano-notifier'
```

and then `bundle install`

## Configure

```rb
require 'capistrano/notifier'

set :notify_method, :test # :smtp, :sendmail, or any other valid ActionMailer delivery method
set :notify_from, "capistrano@domain.com"
set :notify_to, ["john@doe.com", "jane@doe.com"]
set :notify_github_project, "MyCompany/project-name"

namespace :deploy do
  desc "Capistrano Notifier"
  task :notify do
    Capistrano::Notifier.new(self).perform
  end
end

after 'deploy', 'deploy:notify'
```

## Test

```sh
cap deploy:notify
```

