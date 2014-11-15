require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'elasticsearch'

Capybara.default_driver = :poltergeist
Capybara.save_and_open_page_path = File.dirname(__FILE__) + '/var/log/flood/custom'
Capybara.app_host = "http://127.0.0.1"

RSpec.configure do |config|
  config.before(:all) do
    @client = Elasticsearch::Client.new log: false
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
