require File.dirname(__FILE__) + '/../spec_helper'

describe "sign in", type: :feature do
  before :each do
    page.driver.clear_network_traffic if Capybara.default_driver == :poltergeist
  end

  after :each do
    Capybara.default_driver == :poltergeist &&
      page.driver.network_traffic.each do |request|
        @client.index index: "results-#{Time.now.utc.strftime("%Y.%m.%d")}", type: 'capybara', body: {
          timestamp: (Time.now.utc.to_f * 1000).to_i,
          url: request.url,
          request_headers: request.headers.to_s,
          response_headers: request.response_parts.last.headers.to_s,
          start_time: (request.time.to_f * 1000).to_i,
          end_time: (request.response_parts.last.time.to_f * 1000).to_i,
          source_host: 'localhost',
          response_time: (request.response_parts.last.time.to_f * 1000).to_i - (request.time.to_f * 1000).to_i,
          latency: nil,
          sample_count: 1,
          thread_id: 1,
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

  it "should visit homepage" do
    visit '/'
    expect(page).to have_content 'Flood'
  end

  it "should visit features page" do
    visit '/features'
    expect(page).to have_content 'features'
  end
end
