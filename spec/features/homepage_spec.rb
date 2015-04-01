require File.dirname(__FILE__) + '/../spec_helper'
require 'cgi'
require 'pry'

ENV['PUBLIC_IPV4'] ||= `curl -s --fail --connect-timeout 1 http://169.254.169.254/latest/meta-data/public-ipv4 || curl -s --connect-timeout 10 ifconfig.me || echo 127.0.0.1`.chomp

def uri(url)
  if url && !url.empty?
    URI.parse(url).scheme.nil? ? URI.parse("http://#{url}") : URI.parse(url)
  end
end

def parse_path(url)
  uri(url).path if url && !url.empty?
end

describe "sign in", type: :feature do
  before :each do
    page.driver.clear_network_traffic if Capybara.default_driver == :poltergeist
  end

  after :each do
    Capybara.default_driver == :poltergeist &&
      page.driver.network_traffic.each do |request|
        next unless request
        next unless request.response_parts && request.response_parts.any? && request.response_parts.last
        # binding.pry if request.url =~ /stats/
        skip = true if request.response_parts.last.content_type =~ /font|image|css|javascript/
        skip = false if request.headers.to_s =~ /XMLHttpRequest/
        next if skip
        @client.index index: "results-#{Time.now.utc.strftime("%Y.%m.%d")}", type: 'capybara', body: {
          timestamp: (Time.now.utc.to_f * 1000).to_i.to_s,
          url: request.url,
          label:  CGI::escape(parse_path(request.url)),
          request_headers: request.headers.map {|header| header['name'] << '=' << header['value'] }.join(';'),
          response_headers: request.response_parts.last.headers.map {|header| header['name'] << '=' << header['value'] }.join(';'),
          start_time: (request.time.to_f * 1000).to_i.to_s,
          end_time: (request.response_parts.last.time.to_f * 1000).to_i.to_s,
          source_host: ENV['PUBLIC_IPV4'],
          response_time: (request.response_parts.last.time.to_f * 1000).to_i - (request.time.to_f * 1000).to_i,
          latency: nil,
          sample_count: 1,
          thread_id:  ENV['THREAD_ID'] || 1,
          active_threads: ENV['ACTIVE_THREADS'] || ENV['THREAD_ID'] || 1,
          active_threads_in_group: ENV['ACTIVE_THREADS'] || ENV['THREAD_ID'] || 1,
          uuid: ENV['FLOOD_UUID'],
          response_code: request.response_parts.last.status,
          successful: request.response_parts.last.status.to_s.start_with?('2', '3'),
          bytes: request.response_parts.first.body_size,
          request_data: nil,
          response_data: nil
        }
      end
  end

  it "should visit homepage" do
    visit '/wmeS3yIYPs0vM9tFdNQqoQ?grid_id=1'
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
