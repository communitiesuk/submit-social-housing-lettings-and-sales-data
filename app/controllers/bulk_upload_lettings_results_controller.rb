class BulkUploadLettingsResultsController < ApplicationController
  before_action :authenticate_user!

  def show
    @bulk_upload = current_user.bulk_uploads.find(params[:id])
  end
end
