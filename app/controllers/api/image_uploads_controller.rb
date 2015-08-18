class Api::ImageUploadsController < Api::BaseController

  def create
    uploader = ItemUploader.new

    if params[:type] == "item"
      if params[:image]
        uploader.store! params[:image]
      elsif params[:image_url]
        uploader.download! params[:image_url]
        uploader.store!
      end
      ItemUploader.remove_class_variable(:@@id)


      if uploader.url
        body = { :image_url => uploader.url, :image_thumb_url => uploader.thumb.url }
        status = :ok
      end
    end

    body ||= { }
    status ||= :not_acceptable

    # XXX IE 9 requires a text response for photo uploads
    # See https://github.com/blueimp/jQuery-File-Upload/wiki/Setup#content-type-negotiation.
    respond_to do |format|
      format.json { render :json => body,         :status => status }
      format.html { render :text => body.to_json, :status => status }
    end
  end

  #TODO: Implement something to this effect to delete images when a user changes
  #them.  S3 storage is super cheap $0.03 so we don't care until our product
  #hits critical mass.
  #
  # def destroy
    # image.retreive_from_store!(params[:filename])
    # image.destroy
    # head :status => 200
  # end
end
