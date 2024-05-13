class StartController < ApplicationController
  def index
    if current_user
      @homepage_presenter = HomepagePresenter.new(current_user)
      render "home/index"
    end
  end

  def download_24_25_sales_form
    send_file(
      Rails.root.join("public/files/2024_25_sales_paper_form.pdf"),
      filename: "2024-25 Sales paper form.pdf",
      type: "application/pdf",
    )
  end

  def download_23_24_sales_form
    send_file(
      Rails.root.join("public/files/2023_24_sales_paper_form.pdf"),
      filename: "2023-24 Sales paper form.pdf",
      type: "application/pdf",
    )
  end

  def download_24_25_lettings_form
    send_file(
      Rails.root.join("public/files/2024_25_lettings_paper_form.pdf"),
      filename: "2024-25 Lettings paper form.pdf",
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

  def download_24_25_lettings_bulk_upload_template
    send_file(
      Rails.root.join("public/files/bulk-upload-lettings-template-2024-25.xlsx"),
      filename: "2024-25-lettings-bulk-upload-template.xlsx",
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    )
  end

  def download_24_25_lettings_bulk_upload_specification
    send_file(
      Rails.root.join("public/files/bulk-upload-lettings-specification-2024-25.xlsx"),
      filename: "2024-25-lettings-bulk-upload-specification.xlsx",
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    )
  end

  def download_24_25_sales_bulk_upload_template
    send_file(
      Rails.root.join("public/files/bulk-upload-sales-template-2024-25.xlsx"),
      filename: "2024-25-sales-bulk-upload-template.xlsx",
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    )
  end

  def download_24_25_sales_bulk_upload_specification
    send_file(
      Rails.root.join("public/files/bulk-upload-sales-specification-2024-25.xlsx"),
      filename: "2024-25-sales-bulk-upload-specification.xlsx",
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
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

  def download_23_24_sales_bulk_upload_template
    send_file(
      Rails.root.join("public/files/bulk-upload-sales-template-2023-24.xlsx"),
      filename: "2023-24-sales-bulk-upload-template.xlsx",
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    )
  end

  def download_23_24_sales_bulk_upload_legacy_template
    send_file(
      Rails.root.join("public/files/bulk-upload-sales-legacy-template-2023-24.xlsx"),
      filename: "2023-24-sales-bulk-upload-legacy-template.xlsx",
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    )
  end

  def download_23_24_sales_bulk_upload_specification
    send_file(
      Rails.root.join("public/files/bulk-upload-sales-specification-2023-24.xlsx"),
      filename: "2023-24-sales-bulk-upload-specification.xlsx",
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    )
  end
end
