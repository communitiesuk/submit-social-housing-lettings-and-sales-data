class BulkUploadLettingsResultsController < ApplicationController
  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def show
    @bulk_upload = current_user.bulk_uploads.lettings.find(params[:id])
  end
end
