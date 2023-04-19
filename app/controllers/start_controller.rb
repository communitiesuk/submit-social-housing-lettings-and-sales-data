class StartController < ApplicationController
  def index
    if current_user
      redirect_to(lettings_logs_path)
    end
  end

  def download_23_24_sales_form
    send_file(
      Rails.root.join("public/files/2023_24_sales_paper_form.pdf"),
      filename: "2023-24 Sales paper form.pdf",
      type: "application/pdf",
    )
  end

  def download_22_23_sales_form
    send_file(
      Rails.root.join("public/files/2022_23_sales_paper_form.pdf"),
      filename: "2022-23 Sales paper form.pdf",
      type: "application/pdf",
    )
  end

  def download_23_24_lettings_form
    send_file(
      Rails.root.join("public/files/2023_24_lettings_paper_form.pdf"),
      filename: "2023-24 Lettings paper form.pdf",
      type: "application/pdf",
    )
  end

  def download_23_24_lettings_bulk_upload_template
    send_file(
      Rails.root.join("public/files/bulk-upload-lettings-template-2023-24.xlsx"),
      filename: "2023-24-lettings-bulk-upload-template.xlsx",
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    )
  end

  def download_23_24_lettings_bulk_upload_legacy_template
    send_file(
      Rails.root.join("public/files/bulk-upload-lettings-legacy-template-2023-24.xlsx"),
      filename: "2023-24-lettings-bulk-upload-legacy-template.xlsx",
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    )
  end

  def download_23_24_lettings_bulk_upload_specification
    send_file(
      Rails.root.join("public/files/bulk-upload-lettings-specification-2023-24.xlsx"),
      filename: "2023-24-lettings-bulk-upload-specification.xlsx",
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    )
  end

  def download_22_23_lettings_bulk_upload_template
    send_file(
      Rails.root.join("public/files/bulk-upload-lettings-template-2022-23.xlsx"),
      filename: "2022-23-lettings-bulk-upload-template.xlsx",
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    )
  end

  def download_22_23_lettings_bulk_upload_specification
    send_file(
      Rails.root.join("public/files/bulk-upload-lettings-specification-2022-23.xlsx"),
      filename: "2022-23-lettings-bulk-upload-specification.xlsx",
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    )
  end
end
