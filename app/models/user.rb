class User 
  LDAP = UserLdap::Server.
    new({ :host            => LDAP_CONFIG['host'],
          :port            => LDAP_CONFIG['port'],
          :base            => LDAP_CONFIG['user_base'],
          :admin_user      => LDAP_CONFIG['admin_user'],
          :admin_password  => LDAP_CONFIG['admin_password'],
          :connect_timeout => LDAP_CONFIG['connect_timeout'],
          :minter          => LDAP_CONFIG['ark_minter_url']})

  AUTHLOGIC_MAP =
    { 'login'         => 'uid',
      'lastname'      => 'sn',
      'firstname'     => 'givenname',
      'email'         => 'mail',
      'tz_region'     => 'tzregion'}

  def initialize(user)
    @user = user
  end

  def self.find_all
    LDAP.find_all
  end

  def method_missing(meth, *args, &block)
    #simple code to read user information with methods that resemble activerecord slightly
    if !AUTHLOGIC_MAP[meth.to_s].nil? then
      return array_to_value(@user[AUTHLOGIC_MAP[meth.to_s]])
    end
    array_to_value(@user[meth.to_s])
  end
 
  def groups(permission=nil)
    grp_ids = Group::LDAP.find_groups_for_user(self.login, User::LDAP, permission)
    Group.find_batch(grp_ids)
  end

  def self.find_by_id(user_id)
    return User.new(LDAP.fetch(user_id))
  end

  # TODO: figure out whether we still need this & get rid of it if not
  # :nocov:
  #these would be LDAP attributes, not database ones.  maybe they should sync up more to
  #be more active-record-like, but it seems a lot of work to make it completely match AR
  def set_attrib(attribute, value)
    LDAP_USER.replace_attribute(self.login, attribute, value)
  end
  # :nocov:

  def self.valid_ldap_credentials?(uid, password)
    begin
      res = User::LDAP.authenticate(uid, password)
    rescue LdapMixin::LdapException => ex
      return false
    end
    return res && true
  end

  # TODO: figure out whether we still need this & get rid of it if not
  # :nocov:
  def single_value(record, field)
    if record[field].nil? or record[field][0].nil? or record[field][0].length < 1 then
      return nil 
    else
      return record[field][0]
    end
  end
  # :nocov:

  def array_to_value(arr)
    return arr if !arr.is_a?(Array)
    return arr[0] if arr.length == 1
    arr
  end
end
