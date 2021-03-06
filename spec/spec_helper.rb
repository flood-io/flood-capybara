require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'elasticsearch'

Capybara.default_driver = :poltergeist
Capybara.app_host = ENV['APP_HOST'] || "http://127.0.0.1"
Capybara.default_wait_time = 5

RSpec.configure do |config|
  config.before(:all) do
    @client = Elasticsearch::Client.new host: `boot2docker ip`.chomp, log: false
  end
  config.after(:all) do
  end
  config.around(:each) do |example|
    begin
      example.run
    rescue Exception => ex
      save_and_open_page
      raise ex
    end
  end
end
