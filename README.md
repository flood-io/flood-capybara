# Flood::Capybara

![http://www.bay12forums.com/smf/index.php?action=profile;u=22552](http://i.imgur.com/4nAHS.gif)

This gem lets you run your Capybara acceptance tests on Flood IO using RSpec 3.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flood-capybara'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install flood-capybara

## Usage

In your app / rails directory:

```
$ flood-capybara spec \
  --api_token=$FLOOD_API_TOKEN \
  --grid=1QNtoBftrokSErYJdTHRQg \
  --rampup=60 \
  --duration=120 \
  --url=https://flood-newrelic-ruby-kata.herokuapp.com
```

or as a rake task e.g. `lib/tasks/flood.rake`

```
namespace :flood do
  task run: :environment do
    system %{
      flood-capybara spec
      --tag flood
      --api_token=#{ENV['FLOOD_API_TOKEN']}
      --rampup=#{ENV['RAMPUP'] || 60}
      --duration=#{ENV['DURATION'] || 300}
      --url=#{ENV['URL'] || 'https://flood-newrelic-ruby-kata.herokuapp.com'}
    }.squish
  end
end
```

Options available:

- `grid` the Flood IO grid id you want to run this test on.
- `rampup` the rampup time for each capybara instance, note we use a maximum of 8 instances per grid node.
- `duration` how long you want the specs to iterate for. At the moment it will iterate over specs.
- `url` the URL which `Capybara.app_host` will get set to. This is so you can test real / integrated environments.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/flood-capybara/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
