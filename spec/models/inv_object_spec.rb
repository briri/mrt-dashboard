require 'rails_helper'

describe InvObject do
  attr_reader :obj
  attr_reader :collection

  before(:each) do
    @collection = create(:inv_collection, name: 'Collection 1', mnemonic: 'collection_1')
    @obj = create(:inv_object, erc_who: 'Doe, Jane', erc_what: 'Object 1', erc_when: '2018-01-01')
    collection.inv_objects << obj
  end

  describe :bytestream_uri do
    it 'generates the "uri_1" (content) URI' do
      # TODO: figure out why this produces double //s and stop doing it
      expected_uri = "#{APP_CONFIG['uri_1']}#{obj.node_number}/#{obj.to_param}"
      expect(obj.bytestream_uri).to eq(URI.parse(expected_uri))
    end
  end

  describe :bytestream_uri_2 do
    it 'generates the "uri_2" (producer) URI' do
      # TODO: figure out why this produces double //s and stop doing it
      expected_uri = "#{APP_CONFIG['uri_2']}#{obj.node_number}/#{obj.to_param}"
      expect(obj.bytestream_uri2).to eq(URI.parse(expected_uri))
    end
  end

  describe :bytestream_uri_3 do
    it 'generates the "uri_3" (manifest) URI' do
      # TODO: figure out why this produces double //s and stop doing it
      expected_uri = "#{APP_CONFIG['uri_3']}#{obj.node_number}/#{obj.to_param}"
      expect(obj.bytestream_uri3).to eq(URI.parse(expected_uri))
    end
  end

  describe :user_can_download? do
    attr_reader :embargo
    attr_reader :user_id
    attr_reader :collection_id

    before(:each) do
      @embargo = create(:inv_embargo, inv_object: obj)
      @user_id = mock_user(name: 'Jane Doe', password: 'correcthorsebatterystaple')
      @collection_id = mock_ldap_for_collection(collection)
    end

    it 'is false for restricted collection when user has no permissions' do
      collection.download_privilege = 'restricted'
      collection.save!
      expect(obj.user_can_download?(user_id)).to eq(false)
    end

    it 'is false when embargo date is in the future' do
      mock_permissions_read_only(user_id, collection_id)
      embargo.embargo_end_date = Time.now.utc + 1.hours
      expect(obj.user_can_download?(user_id)).to eq(false)
    end

    it 'is true when embargo date is in the past' do
      mock_permissions_read_only(user_id, collection_id)
      embargo.embargo_end_date = Time.now.utc - 1.hours
      expect(obj.user_can_download?(user_id)).to eq(true)
    end

    it 'is true when user has admin permission' do
      mock_permissions_all(user_id, collection_id)

      embargo.embargo_end_date = Time.now.utc + 1.hours
      expect(obj.user_can_download?(user_id)).to eq(true)
    end

  end

end
