module AccessMixin
  include UserAndGroupMixin

  # Returns true if the user can upload to the session group
  def current_user_can_write_to_collection?
    session[:group_id] && current_group.user_has_permission?(current_uid, 'write')
  end

  def current_user_can_download?(object)
    object.user_can_download?(current_uid)
  end
end
