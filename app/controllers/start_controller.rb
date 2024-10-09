class StartController < ApplicationController
  include CollectionResourcesHelper

  def index
    if current_user
      @homepage_presenter = HomepagePresenter.new(current_user)
      render "home/index"
    end
  end

  def download_24_25_sales_form
    download_resource("2024_25_sales_paper_form.pdf", "2024-25 Sales paper form.pdf")
  end

  def download_23_24_sales_form
    download_resource("2023_24_sales_paper_form.pdf", "2023-24 Sales paper form.pdf")
  end

  def download_24_25_lettings_form
    download_resource("2024_25_lettings_paper_form.pdf", "2024-25 Lettings paper form.pdf")
  end

  def download_23_24_lettings_form
    download_resource("2023_24_lettings_paper_form.pdf", "2023-24 Lettings paper form.pdf")
  end

  def download_24_25_lettings_bulk_upload_template
    download_resource("bulk-upload-lettings-template-2024-25.xlsx", "2024-25-lettings-bulk-upload-template.xlsx")
  end

  def download_24_25_lettings_bulk_upload_specification
    download_resource("bulk-upload-lettings-specification-2024-25.xlsx", "2024-25-lettings-bulk-upload-specification.xlsx")
  end

  def download_24_25_sales_bulk_upload_template
    download_resource("bulk-upload-sales-template-2024-25.xlsx", "2024-25-sales-bulk-upload-template.xlsx")
  end

  def download_24_25_sales_bulk_upload_specification
    download_resource("bulk-upload-sales-specification-2024-25.xlsx", "2024-25-sales-bulk-upload-specification.xlsx")
  end

  def download_23_24_lettings_bulk_upload_template
    download_resource("bulk-upload-lettings-template-2023-24.xlsx", "2023-24-lettings-bulk-upload-template.xlsx")
  end

  def download_23_24_lettings_bulk_upload_legacy_template
    download_resource("bulk-upload-lettings-legacy-template-2023-24.xlsx", "2023-24-lettings-bulk-upload-legacy-template.xlsx")
  end

  def download_23_24_lettings_bulk_upload_specification
    download_resource("bulk-upload-lettings-specification-2023-24.xlsx", "2023-24-lettings-bulk-upload-specification.xlsx")
  end

  def download_23_24_sales_bulk_upload_template
    download_resource("bulk-upload-sales-template-2023-24.xlsx", "2023-24-sales-bulk-upload-template.xlsx")
  end

  def download_23_24_sales_bulk_upload_legacy_template
    download_resource("bulk-upload-sales-legacy-template-2023-24.xlsx", "2023-24-sales-bulk-upload-legacy-template.xlsx")
  end

  def download_23_24_sales_bulk_upload_specification
    download_resource("bulk-upload-sales-specification-2023-24.xlsx", "2023-24-sales-bulk-upload-specification.xlsx")
  end

private

  def download_resource(filename, download_filename)
    file = CollectionResourcesService.new.get_file(filename)
    return render_not_found unless file

    send_data(file, disposition: "attachment", filename: download_filename)
  end
end
