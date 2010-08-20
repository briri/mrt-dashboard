require 'rest_client'
require 'ftools'

class ObjectController < ApplicationController
  before_filter :require_user
  before_filter :require_group

  def index
    
  end

  def upload
    new_file = DataFile.save(params[:file], current_user.login)

    hsh = {
        'file'              => File.new(new_file, 'rb'),
        'type'              => params[:object_type],
        'submitter'         => current_user.displayname, # is this user in mark's example (submitter)
        'filename'          => params[:file].original_filename, # is this necessary?
        'profile'           => 'profileSFISHER', # XXX this needs to be changed
        'creator'           => params[:author],
        'title'             => params[:title],
        'date'              => params[:date],
        'localIdentifier'   => params[:local_id], # local identifier necessary, nulls?
        'responseForm'      => 'xml'
      }

    hsh.delete_if{|key, value| value.nil? or (value.class == String and value.strip.eql?(''))}

    response = RestClient.post(INGEST_SERVICE,
                hsh,
                {#"Content-Type" => 'application/octet-stream',
                 #"Content-Length" => File.size(new_file),
                 "Accept" => 'application/xml',
                 :multipart => true
                }
           )

    File.delete(new_file)
    @doc = Nokogiri::XML(response) do |config|
      config.strict.noent.noblanks
    end
    
    @batch_id = @doc.xpath("//bat:batchState/bat:batchID")[0].child.text
    @obj_count = @doc.xpath("//bat:batchState/bat:jobStates").length

  end
end
