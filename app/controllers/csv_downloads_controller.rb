class CsvDownloadsController < ApplicationController
  before_action :authenticate_user!

  def download
    csv_download = CsvDownload.find(params[:id])
    authorize csv_download

    return render "errors/download_link_expired" if csv_download.expired?

    downloader = Csv::Downloader.new(csv_download:)

    if Rails.env.development?
      downloader.call
      send_file downloader.path, filename: csv_download.filename, type: "text/csv"
    else
      presigned_url = downloader.presigned_url
      redirect_to presigned_url, allow_other_host: true
    end
  end
end
