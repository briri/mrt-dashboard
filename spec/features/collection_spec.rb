require 'features_helper'

describe 'collections' do
  attr_reader :user_id
  attr_reader :password

  attr_reader :inv_collection_1
  attr_reader :collection_1_id

  before(:each) do
    @password = 'correcthorsebatterystaple'
    @user_id = mock_user(name: 'Jane Doe', password: password)

    @inv_collection_1 = create(:inv_collection, name: 'Collection 1', mnemonic: 'collection_1')
    @collection_1_id = mock_ldap_for_collection(inv_collection_1)
    mock_permissions_all(user_id, collection_1_id)
  end

  it 'should display the collection name' do
    log_in_with(user_id, password)
    expect(page).to have_content("Collection: #{inv_collection_1.name}")
  end

  describe 'objects' do
    attr_reader :inv_objects

    before(:each) do
      @inv_objects = Array.new(3) do |i|
        create(
          :inv_object,
          erc_who: 'Doe, Jane',
          erc_what: "Object #{i}",
          erc_when: "2018-01-0#{i}"
        )
      end
      inv_collection_1.inv_objects << inv_objects
      log_in_with(user_id, password)
    end

    it 'should list the objects' do
      inv_objects.each do |obj|
        expect(page).to have_content(obj.ark)
        expect(page).to have_content(obj.erc_who)
        expect(page).to have_content(obj.erc_what)
        expect(page).to have_content(obj.erc_when)
      end
    end

    it 'should let the user navigate to an object' do
      obj = inv_objects[0]
      click_link(obj.ark)
      expect(page).to have_content("Object: #{obj.ark}")
    end

    it 'should display an "Add Object" link' do
      add_obj_link = find_link('Add object')
      expect(add_obj_link).not_to be_nil
      add_obj_link.click
      expect(page.title).to include('Add Object')
    end

  end
end
