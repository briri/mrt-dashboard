class InvCollection < ActiveRecord::Base
  has_many :inv_collections_inv_objects
  has_many :inv_objects, through: :inv_collections_inv_objects

  include Encoder

  def to_param
    urlencode(ark)
  end

  def group
    @_group ||= Group.find(ark)
  end

  def recent_objects
    inv_objects
      .quickloadhack
      .order('inv_objects.modified desc')
      .includes(:inv_versions, :inv_dublinkernels)
  end

  def read_public?
    read_privilege == 'public'
  end

  def download_public?
    download_privilege == 'public'
  end

  def user_has_read_permission?(uid)
    read_public? || group.user_has_read_permission?(uid)
  end

  def user_has_download_permission?(uid)
    download_public? || group.user_has_permission?(uid, 'download')
  end

end
