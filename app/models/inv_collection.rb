class InvCollection < ActiveRecord::Base
  has_many :inv_collections_inv_objects
  has_many :inv_objects, through: :inv_collections_inv_objects

  include Encoder

  def to_param
    Encoder.urlencode(ark)
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
end
