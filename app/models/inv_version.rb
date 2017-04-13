class InvVersion < ActiveRecord::Base
  belongs_to :inv_object, :inverse_of => :inv_versions
  has_many :inv_files, :inverse_of => :inv_version
  has_many :inv_dublinkernels

  def to_param
    self.number
  end

  def permalink
    "#{APP_CONFIG['merritt_server']}/m/#{self.inv_object.to_param}/#{self.to_param}"
  end
  
  def bytestream_uri 
    URI.parse("#{APP_CONFIG['uri_1']}#{self.inv_object.node_number}/#{self.inv_object.to_param}/#{self.to_param}")
  end

  def bytestream_uri2 
    URI.parse("#{APP_CONFIG['uri_2']}#{self.inv_object.node_number}/#{self.inv_object.to_param}/#{self.to_param}")
  end

  def total_size
    self.inv_files.sum("full_size")
  end

  def system_files 
    self.inv_files.system_files.order(:pathname)
  end

  def producer_files 
    self.inv_files.producer_files.order(:pathname)
  end

  def metadata(element)
    self.inv_dublinkernels.select {|md| md.element == element && md.value != "(:unas)"}.map {|md| md.value }
  end

  def dk_who
    self.metadata('who')
  end

  def dk_what
    self.metadata('what')
  end

  def dk_when
    self.metadata('when')
  end

  def dk_where
    self.metadata('where')
  end
  
  def local_id
    self.dk_where.reject {|v| v == self.ark }
  end

  def total_actual_size
    self.inv_files.sum("full_size")
  end
end
