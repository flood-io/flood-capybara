# Flood::Capybara

![](http://i.imgur.com/4nAHS.gif)

This gem lets you run your Capybara acceptance tests on Flood IO. At the moment it supports the RSpec 3 runner only. Plans to include other test runners in the near future.

This works by essetinally parsing specs from your specs directory, wrapping them up and running them on Flood IO with a specialised docker container (using phantomjs / poltergeist)

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

    $ flood-capybara spec --api_token=$FLOOD_API_TOKEN --grid_id=1QNtoBftrokSErYJdTHRQg --duration=120 --url=https://flood.io

Options available:

- `grid_id` the Flood IO grid id you want to run this test on.
- `rampup` the rampup time for each capybara instance, note we use a maximum of 8 instances per grid node.
- `duration` how long you want the specs to iterate for. At the moment it will iterate over specs.
- `url` the URL which `Capybara.app_host` will get set to. This is so you can test real / integrated environments.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/flood-capybara/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
