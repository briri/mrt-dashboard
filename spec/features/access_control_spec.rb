require 'features_helper'

describe 'access control' do
  attr_reader :password
  attr_reader :user_id

  attr_reader :other_password
  attr_reader :other_user_id

  attr_reader :collection
  attr_reader :collection_id

  attr_reader :object
  attr_reader :basenames

  attr_reader :version

  def collection_index
    @collection_index ||= url_for(controller: :collection, action: :index, group: collection_id, only_path: true)
  end

  def object_index
    @object_index ||= url_for(controller: :object, action: :index, object: object.ark, only_path: true)
  end

  def version_index
    @version_index ||= url_for(controller: :version, action: :index, object: object.ark, version: version.number, only_path: true)
  end

  def init_object!
    @object = create(:inv_object, erc_who: 'Doe, Jane', erc_what: 'Object 1', erc_when: '2018-01-01')
    collection.inv_objects << object
    @version = object.current_version

    producer_files = Array.new(3) { |i| init_file(i) }
    @basenames = producer_files.map { |f| f.pathname.sub(%r{^producer/}, '') }
  end

  def init_file(i)
    size = 1024 * (2**i)
    create(
      :inv_file,
      inv_object: object,
      inv_version: object.current_version,
      pathname: "producer/file-#{i}.bin",
      full_size: size,
      billable_size: size,
      mime_type: 'application/octet-stream'
    )
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
      init_object!
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

    describe 'object' do
      it 'should allow user access' do
        log_in_with(user_id, password)
        visit(object_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).to have_button('Download object')
        basenames.each { |b| expect(page).to have_link(b) }
      end

      it 'should not allow guest access' do
        log_in_as_guest!
        visit(object_index)
        expect(page).to have_content('Not authorized')
        expect(page).not_to have_content("Object: #{object.ark}")
        expect(page).not_to have_button('Download object')
        basenames.each { |b| expect(page).not_to have_link(b) }
      end

      it 'should not allow access w/o login' do
        visit(object_index)
        expect(page).to have_content('Not authorized')
        expect(page).not_to have_content("Object: #{object.ark}")
        expect(page).not_to have_button('Download object')
        basenames.each { |b| expect(page).not_to have_link(b) }
      end

      it 'should not allow access for users w/o specific permissions' do
        log_in_with(other_user_id, other_password)
        visit(object_index)
        expect(page).to have_content('Not authorized')
        expect(page).not_to have_content("Object: #{object.ark}")
        expect(page).not_to have_button('Download object')
        basenames.each { |b| expect(page).not_to have_link(b) }
      end
    end

    describe 'version' do
      it 'should allow user access' do
        log_in_with(user_id, password)
        visit(version_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).to have_content("Version #{version.number}")
        expect(page).to have_button('Download version')
        basenames.each { |b| expect(page).to have_link(b) }
      end

      it 'should not allow guest access' do
        log_in_as_guest!
        visit(version_index)
        expect(page).to have_content('Not authorized')
        expect(page).not_to have_content("Object: #{object.ark}")
        expect(page).not_to have_content("Version #{version.number}")
        expect(page).not_to have_button('Download version')
        basenames.each { |b| expect(page).not_to have_link(b) }
      end

      it 'should not allow access w/o login' do
        visit(version_index)
        expect(page).to have_content('Not authorized')
        expect(page).not_to have_content("Object: #{object.ark}")
        expect(page).not_to have_content("Version #{version.number}")
        expect(page).not_to have_button('Download version')
        basenames.each { |b| expect(page).not_to have_link(b) }
      end

      it 'should not allow access for users w/o specific permissions' do
        log_in_with(other_user_id, other_password)
        visit(version_index)
        expect(page).to have_content('Not authorized')
        expect(page).not_to have_content("Object: #{object.ark}")
        expect(page).not_to have_content("Version #{version.number}")
        expect(page).not_to have_button('Download version')
        basenames.each { |b| expect(page).not_to have_link(b) }
      end
    end
  end

  describe 'public collection' do
    before(:each) do
      @collection = create(:inv_collection, name: 'Public Collection', mnemonic: 'public_collection')
      @collection_id = mock_ldap_for_collection(collection)
      mock_permissions_all(user_id, collection_id)
      init_object!
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

    describe 'object' do
      it 'should allow user access' do
        log_in_with(user_id, password)
        visit(object_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).to have_button('Download object')
        basenames.each { |b| expect(page).to have_link(b) }
      end

      it 'should allow guest access' do
        log_in_as_guest!
        visit(object_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).to have_button('Download object')
        basenames.each { |b| expect(page).to have_link(b) }
      end

      it 'should allow access w/o login' do
        visit(object_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).to have_button('Download object')
        basenames.each { |b| expect(page).to have_link(b) }
      end

      it 'should allow access for users w/o specific permissions' do
        log_in_with(other_user_id, other_password)
        visit(object_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).to have_button('Download object')
        basenames.each { |b| expect(page).to have_link(b) }
      end
    end

    describe 'version' do
      it 'should allow user access' do
        log_in_with(user_id, password)
        visit(version_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).to have_content("Version #{version.number}")
        expect(page).to have_button('Download version')
        basenames.each { |b| expect(page).to have_link(b) }
      end

      it 'should allow guest access' do
        log_in_as_guest!
        visit(version_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).to have_content("Version #{version.number}")
        expect(page).to have_button('Download version')
        basenames.each { |b| expect(page).to have_link(b) }
      end

      it 'should allow access w/o login' do
        visit(version_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).to have_content("Version #{version.number}")
        expect(page).to have_button('Download version')
        basenames.each { |b| expect(page).to have_link(b) }
      end

      it 'should allow access for users w/o specific permissions' do
        log_in_with(other_user_id, other_password)
        visit(version_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).to have_content("Version #{version.number}")
        expect(page).to have_button('Download version')
        basenames.each { |b| expect(page).to have_link(b) }
      end
    end
  end

  describe 'public collection w/restricted downloads' do
    before(:each) do
      @collection = create(:download_restricted_collection, name: 'Download-Restricted Collection', mnemonic: 'dr_collection')
      @collection_id = mock_ldap_for_collection(collection)
      mock_permissions_all(user_id, collection_id)
      init_object!
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

    describe 'object' do
      it 'should allow user access & download' do
        log_in_with(user_id, password)
        visit(object_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).to have_button('Download object')
        basenames.each { |b| expect(page).to have_link(b) }
      end

      it 'should allow guest access, but not download' do
        log_in_as_guest!
        visit(object_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).not_to have_button('Download object')
        expect(page).to have_content('You do not have permission to download this object.')
        basenames.each { |b| expect(page).not_to have_link(b) }
      end

      it 'should allow access, but not download, w/o login' do
        visit(object_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).not_to have_button('Download object')
        expect(page).to have_content('You do not have permission to download this object.')
        basenames.each { |b| expect(page).not_to have_link(b) }
      end

      it 'should allow access, but not download, for users w/o specific permissions' do
        log_in_with(other_user_id, other_password)
        visit(object_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).not_to have_button('Download object')
        expect(page).to have_content('You do not have permission to download this object.')
        basenames.each { |b| expect(page).not_to have_link(b) }
      end
    end

    describe 'version' do
      it 'should allow user access & download' do
        log_in_with(user_id, password)
        visit(version_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).to have_content("Version #{version.number}")
        expect(page).to have_button('Download version')
        basenames.each { |b| expect(page).to have_link(b) }
      end

      it 'should allow guest access, but not download' do
        log_in_as_guest!
        visit(version_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).to have_content("Version #{version.number}")
        expect(page).not_to have_button('Download version')
        expect(page).to have_content('You do not have permission to download this object.')
        basenames.each { |b| expect(page).not_to have_link(b) }
      end

      it 'should allow access, but not download, w/o login' do
        visit(version_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).to have_content("Version #{version.number}")
        expect(page).not_to have_button('Download version')
        expect(page).to have_content('You do not have permission to download this object.')
        basenames.each { |b| expect(page).not_to have_link(b) }
      end

      it 'should allow access, but not download, for users w/o specific permissions' do
        log_in_with(other_user_id, other_password)
        visit(version_index)
        expect(page).not_to have_content('Not authorized')
        expect(page).to have_content("Object: #{object.ark}")
        expect(page).to have_content("Version #{version.number}")
        expect(page).not_to have_button('Download version')
        expect(page).to have_content('You do not have permission to download this object.')
        basenames.each { |b| expect(page).not_to have_link(b) }
      end
    end
  end
end
