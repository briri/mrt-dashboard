require 'rails_helper'
require 'capybara/dsl'
require 'capybara/rails'
require 'capybara/rspec'

# ------------------------------------------------------------
# Capybara etc.

# Ideally we'd set a minimum Chromedriver version, but that's not an
# option; see https://github.com/flavorjones/chromedriver-helper
Chromedriver.set_version('2.38')

Capybara.register_driver(:selenium) do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: Selenium::WebDriver::Chrome::Options.new(args: %w[incognito no-sandbox disable-gpu'])
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
# LDAP

def mock_ldap!
  test_user_id = 'testuser01'
  test_password = test_user_id
  test_user_ldap =   {
    'dn' => ["uid=#{test_user_id},ou=People,ou=uc3,dc=cdlib,dc=org"],
    'objectclass' => ["person", "inetOrgPerson", "merrittUser", "organizationalPerson", "top"],
    'givenname' => ["Test"],
    'uid' => [test_user_id],
    'mail' => ["test@example.edu"],
    'sn' => ["Submitter"],
    'cn' => ["Test User 01"],
    'arkid' => ["ark:/99999/fk_testuser01"]
  }

  allow(User::LDAP).to receive(:authenticate).and_raise(LdapMixin::LdapException)
  allow(User::LDAP).to receive(:authenticate).with(test_user_id, test_password).and_return(true)
  allow(User::LDAP).to receive(:fetch).with(test_user_id).and_return(test_user_ldap)

  test_group_id = 'testgroup01'
  test_group_ldap = {
    'ou' => [test_group_id],
    'submissionprofile' => ['test_profile'],
    'arkid' => ['ark:/99999/fk_testgroup01'],
    'description' => 'Test Group 01'
  }

  allow(Group::LDAP).to receive(:find_groups_for_user).with(test_user_id, any_args).and_return([test_group_id])
  allow(Group::LDAP).to receive(:fetch_batch).with([test_group_id]).and_return([test_group_ldap])
  allow(Group::LDAP).to receive(:fetch).with(test_group_id).and_return(test_group_ldap)

  allow(Group::LDAP).to receive(:get_user_permissions).with(test_user_id, test_group_id, User::LDAP).and_return(["read", "write", "download", "admin"])
end

RSpec.configure do |config|
  config.before(:each) do |_example| # mocks are only available in example context
    mock_ldap!
  end
end

# ------------------------------------------------------------
# Capybara helpers

def log_in!
  visit login_path
  fill_in "login", :with => "testuser01"
  fill_in "password", :with => "testuser01"
  click_button "Login"
end
