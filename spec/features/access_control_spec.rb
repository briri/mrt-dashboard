require 'features_helper'

describe 'access control' do
  attr_reader :password
  attr_reader :user_id

  attr_reader :other_password
  attr_reader :other_user_id

  attr_reader :collection
  attr_reader :collection_id

  def collection_index
    url_for(controller: :collection, action: :index, group: collection_id, only_path: true)
  end

  before(:each) do
    @password = 'correcthorsebatterystaple'
    @user_id = mock_user(name: 'Jane Doe', password: password)

    @other_password = 'T0ub4dor&3'
    @other_user_id = mock_user(name: 'Rachel Roe', password: other_password)
  end

  describe 'private collection' do
    before(:each) do
      @collection = create(:private_collection, name: 'Private Collection', mnemonic: 'private_collection')
      @collection_id = mock_ldap_for_collection(collection)
      mock_permissions_all(user_id, collection_id)
    end

    describe 'collection' do
      it 'should allow user access' do
        log_in_with(user_id, password)
        visit(collection_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Collection: #{collection.name}")
      end

      it 'should not allow guest access' do
        log_in_as_guest!
        visit(collection_index)
        expect(page).to have_content('Not authorized')
        expect(page).not_to have_content("Collection: #{collection.name}")
      end

      it 'should not allow access w/o login' do
        visit(collection_index)
        expect(page).to have_content('Not authorized')
        expect(page).not_to have_content("Collection: #{collection.name}")
      end

      it 'should not allow access for users w/o specific permissions' do
        log_in_with(other_user_id, other_password)
        visit(collection_index)
        expect(page).to have_content('Not authorized')
        expect(page).not_to have_content("Collection: #{collection.name}")
      end
    end

    describe 'object'
    describe 'version'
  end

  describe 'public collection' do
    before(:each) do
      @collection = create(:inv_collection, name: 'Public Collection', mnemonic: 'public_collection')
      @collection_id = mock_ldap_for_collection(collection)
      mock_permissions_all(user_id, collection_id)
    end

    describe 'collection' do
      it 'should allow user access' do
        log_in_with(user_id, password)
        visit(collection_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Collection: #{collection.name}")
      end

      it 'should allow guest access' do
        log_in_as_guest!
        visit(collection_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Collection: #{collection.name}")
      end

      it 'should allow access w/o login' do
        visit(collection_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Collection: #{collection.name}")
      end

      it 'should allow access for users w/o specific permissions' do
        log_in_with(other_user_id, other_password)
        visit(collection_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Collection: #{collection.name}")
      end
    end

    describe 'object'
    describe 'version'
  end

  describe 'public collection w/restricted downloads' do
    before(:each) do
      @collection = create(:download_restricted_collection, name: 'Download-Restricted Collection', mnemonic: 'dr_collection')
      @collection_id = mock_ldap_for_collection(collection)
      mock_permissions_all(user_id, collection_id)
    end

    describe 'collection' do
      it 'should allow user access' do
        log_in_with(user_id, password)
        visit(collection_index)
        expect(page).not_to have_content('Not authorized')
      end

      it 'should allow guest access' do
        log_in_as_guest!
        visit(collection_index)
        expect(page).not_to have_content('Not authorized')
      end

      it 'should allow access w/o login' do
        visit(collection_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Collection: #{collection.name}")
      end

      it 'should allow access for users w/o specific permissions' do
        log_in_with(other_user_id, other_password)
        visit(collection_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Collection: #{collection.name}")
      end
    end

    describe 'object'
    describe 'version'
  end
end
