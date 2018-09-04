module AccessMixin
  include UserAndGroupMixin

  def current_user_can_read?(anything)
    anything.user_has_read_permission?(current_uid)
  end

  def current_user_can_download?(object)
    object.user_can_download?(current_uid)
  end

  def current_user_can_write?(group)
    session[:group_id] && group.user_has_permission?(current_uid, 'write')
  end

  def current_user_can_write_to_collection?
    current_user_can_write?(current_group)
  end
end
