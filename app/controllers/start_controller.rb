class StartController < ApplicationController
  include CollectionTimeHelper

  def index
    if current_user
      @homepage_presenter = HomepagePresenter.new(current_user)
      render "home/index"
    end
  end

  FormHandler.instance.years_of_available_lettings_forms.each do |year|
    short_underscored_year = "#{year % 100}_#{(year + 1) % 100}"
    underscored_year = "#{year}_#{(year + 1) % 100}"
    dasherised_year = underscored_year.dasherize

    define_method "download_#{short_underscored_year}_lettings_form" do
      download_resource("#{underscored_year}_lettings_paper_form.pdf", "#{dasherised_year}-lettings-paper-form.pdf")
    end

    define_method "download_#{short_underscored_year}_lettings_bulk_upload_template" do
      download_resource("bulk-upload-lettings-template-#{dasherised_year}.xlsx", "#{dasherised_year}-lettings-bulk-upload-template.xlsx")
    end

    define_method "download_#{short_underscored_year}_lettings_bulk_upload_specification" do
      download_resource("bulk-upload-lettings-specification-#{dasherised_year}.xlsx", "#{dasherised_year}-lettings-bulk-upload-specification.xlsx")
    end
  end

  FormHandler.instance.years_of_available_sales_forms.each do |year|
    short_underscored_year = "#{year % 100}_#{(year + 1) % 100}"
    underscored_year = "#{year}_#{(year + 1) % 100}"
    dasherised_year = underscored_year.dasherize

    define_method "download_#{short_underscored_year}_sales_form" do
      download_resource("#{underscored_year}_sales_paper_form.pdf", "#{dasherised_year}-sales-paper-form.pdf")
    end

    define_method "download_#{short_underscored_year}_sales_bulk_upload_template" do
      download_resource("bulk-upload-sales-template-#{dasherised_year}.xlsx", "#{dasherised_year}-sales-bulk-upload-template.xlsx")
    end

    define_method "download_#{short_underscored_year}_sales_bulk_upload_specification" do
      download_resource("bulk-upload-sales-specification-#{dasherised_year}.xlsx", "#{dasherised_year}-sales-bulk-upload-specification.xlsx")
    end
  end

  def download_23_24_lettings_bulk_upload_legacy_template
    download_resource("bulk-upload-lettings-legacy-template-2023-24.xlsx", "2023-24-lettings-bulk-upload-legacy-template.xlsx")
  end

  def download_23_24_sales_bulk_upload_legacy_template
    download_resource("bulk-upload-sales-legacy-template-2023-24.xlsx", "2023-24-sales-bulk-upload-legacy-template.xlsx")
  end

private

  def download_resource(file, filename)
    url = "https://#{Rails.application.config.collection_resources_s3_bucket_name}.s3.amazonaws.com/#{file}"
    uri = URI.parse(url)

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(uri)
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      send_data(response.body, disposition: "attachment", filename:)
    else
      render_not_found
    end
  end
end
