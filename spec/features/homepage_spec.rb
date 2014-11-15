require File.dirname(__FILE__) + '/../spec_helper'
require 'cgi'

ENV['PUBLIC_IPV4'] ||= `curl -s --fail --connect-timeout 1 http://169.254.169.254/latest/meta-data/public-ipv4 || curl -s --connect-timeout 10 ifconfig.me || echo 127.0.0.1`.chomp

describe "sign in", type: :feature do
  before :each do
    page.driver.clear_network_traffic if Capybara.default_driver == :poltergeist
  end

  after :each do
    Capybara.default_driver == :poltergeist &&
      page.driver.network_traffic.each do |request|
        @client.index index: "results-#{Time.now.utc.strftime("%Y.%m.%d")}", type: 'capybara', body: {
          timestamp: (Time.now.utc.to_f * 1000).to_i.to_s,
          url: request.url,
          label:  CGI::escape(request.url),
          request_headers: request.headers.to_s,
          response_headers: request.response_parts.last.headers.to_s,
          start_time: (request.time.to_f * 1000).to_i.to_s,
          end_time: (request.response_parts.last.time.to_f * 1000).to_i.to_s,
          source_host: ENV['PUBLIC_IPV4'],
          response_time: (request.response_parts.last.time.to_f * 1000).to_i - (request.time.to_f * 1000).to_i,
          latency: nil,
          sample_count: 1,
          thread_id:  ENV['THREAD_ID'] || 1,
          active_threads: 1,
          active_threads_in_group: 1,
          uuid: ENV['FLOOD_UUID'],
          response_code: request.response_parts.last.status,
          bytes: 0,
          request_data: nil,
          response_data: nil
        }
      end
  end

  it "should just work" do
    visit '/'
    expect(page).to have_content 'Flood'
  end
end

describe "navigate", type: :feature do
  it "should visit homepage" do
    visit '/'
    expect(page).to have_content 'Flood'
  end

  it "should visit features page" do
    visit '/features'
    expect(page).to have_content 'Features'
  end

  it "should visit pricing page" do
    visit '/pricing'
    expect(page).to have_content 'Pricing'
  end

  it "should visit faq page" do
    visit '/faq'
    expect(page).to have_content 'Frequently Asked Questions'
  end

  it "should visit broken page" do
    visit '/broken'
    expect(page).to have_content '404'
  end
end
