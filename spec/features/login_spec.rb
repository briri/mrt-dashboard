require 'features_helper'

describe 'login' do
  attr_reader :user_id
  attr_reader :user_name
  attr_reader :password

  before(:each) do
    @user_name = 'Jane Doe'
    @password = 'correcthorsebatterystaple'
    @user_id = mock_user(name: user_name, password: password)

    collection = create(:private_collection, name: 'Private Collection', mnemonic: 'private_collection')
    collection_id = mock_ldap_for_collection(collection)
    mock_permissions_all(user_id, collection_id)
  end

  after(:each) do
    log_out!
  end

  it 'accepts valid credentials' do
    log_in_with(user_id, password)
    expect(page).not_to have_content('Login unsuccessful')
    expect(page).to have_content('Logout')
    expect(page).to have_content("Logged in as #{user_name}")
  end

  it 'supports logout' do
    log_in_with(user_id, password)
    logout_link = find_link('Logout')
    logout_link.click
    expect(page).not_to have_content('Logged in')
    expect(page).to have_content('Login')
  end

  it 'rejects invalid credentials' do
    log_in_with("not #{user_id}", "not #{password}")
    expect(page).to have_content('Login unsuccessful')
  end

end
