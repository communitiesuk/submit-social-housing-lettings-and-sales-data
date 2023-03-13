class StartController < ApplicationController
  def index
    if current_user
      redirect_to(lettings_logs_path)
    end
  end

  def download_pdf
    send_file(
      Rails.root.join("public/files/2023_24_sales_paper_form.pdf"),
      filename: "2023-24 Sales paper form.pdf",
      type: "application/pdf",
    )
  end
end
