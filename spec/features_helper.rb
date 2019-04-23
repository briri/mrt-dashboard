require 'rails_helper'
require 'capybara/dsl'
require 'capybara/rails'
require 'capybara/rspec'
require 'support/downloads'
require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:each) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end
  config.after(:each) do
    Downloads.clear!
  end
  config.after(:all) do
    Downloads.remove_directory!
  end
end

# ------------------------------------------------------------
# Capybara etc.

Capybara.register_driver(:selenium) do |app|
  profile = Selenium::WebDriver::Chrome::Profile.new
  profile['download.default_directory'] = Downloads.dir

  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[incognito no-sandbox disable-gpu]
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    profile: profile,
    options: options
  )
end

Capybara.javascript_driver = :chrome

Capybara.configure do |config|
  config.default_max_wait_time = 10
  config.default_driver = :selenium
  config.server_port = 33_000
  config.app_host = 'http://localhost:33000'
end

Capybara.server = :puma

# ------------------------------------------------------------
# Capybara helpers

def wait_for_ajax!
  Timeout.timeout(Capybara.default_max_wait_time) do
    loop until page.evaluate_script("(typeof Ajax === 'undefined') ? 0 : Ajax.activeRequestCount").zero?
  end
end

def log_in_with(user_id, password)
  visit login_path
  fill_in 'login', with: user_id
  fill_in 'password', with: password
  click_button 'Login'
  wait_for_ajax!
end

def log_out!
  # faster than unless page.has_content?, see https://blog.codeship.com/faster-rails-tests/
  # return if page.has_no_content?('Logout')
  return unless page.text.include?('Logout')

  click_link('Logout', match: :first)
end
