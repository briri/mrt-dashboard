module UserAndGroupMixin
  # Return the groups which the user may be a member of
  def available_groups
    # Return the groups which the user may be a member ofdef available_groups
    @available_groups ||= begin
      current_user.groups
        .sort_by { |g| g.description.downcase }
        .map { |g| { id: g.id, description: g.description, user_permissions: g.user_permissions(current_user.login) } }
    end
  end

  private

  def current_group
    @_current_group ||= Group.find(session[:group_id])
  end

  def current_user_displayname
    session[:user_displayname] ||= current_user.displayname
  end

  # either return the uid from the session OR get the user id from
  # basic auth. Will not hit LDAP unless using basic auth
  def current_uid
    session[:uid] || (current_user && current_user.uid)
  end

  # Return the current user. Uses either the session user OR if the
  # user supplied HTTP basic auth info, uses that. Returns nil if
  # there is no session user and HTTP basic auth did not succeed
  def current_user
    @current_user ||= begin
      User.find_by_id(session[:uid]) || User.from_auth_header(request.headers['HTTP_AUTHORIZATION'])
    end
  end
end
