class CsvDownloadPolicy
  attr_reader :current_user, :csv_download

  def initialize(current_user, csv_download)
    @current_user = current_user
    @csv_download = csv_download
  end

  def show?
    @current_user == @csv_download.user || @current_user.support? || @current_user.organisation == @csv_download.organisation
  end

  def download?
    @current_user == @csv_download.user || @current_user.support? || @current_user.organisation == @csv_download.organisation
  end
end
