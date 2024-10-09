require "rails_helper"

RSpec.describe "Collection resources" do
  let(:user) { create(:user, :support) }
  let(:collection_resources_service) { instance_double(CollectionResourcesService, file_exists_on_s3?: true) }

  before do
    allow(CollectionResourcesService).to receive(:new).and_return(collection_resources_service)
    allow(collection_resources_service).to receive(:upload_collection_resource)
    allow(collection_resources_service).to receive(:get_file_metadata).and_return({ "Content-Type" => "application/pdf", "Content-Length" => 1000 })
    allow(user).to receive(:need_two_factor_authentication?).and_return(false)
    sign_in user
  end

  context "when uploading paper form" do
    it "only allows pdf files for lettings" do
      visit("/collection-resources/lettings/2024/paper_form/edit")

      click_button("Save changes")

      expect(page).to have_content("Select which file to upload")

      expect(page).to have_content("Change the paper form")
      expect(page).to have_content("Lettings 2024 to 2025")

      attach_file "file", file_fixture("excel_file.xlsx")
      click_button("Save changes")

      expect(page).to have_content("The paper form must be a PDF.")

      attach_file "file", file_fixture("pdf_file.pdf")
      click_button("Save changes")

      expect(page).not_to have_content("The paper form must be a PDF.")
      expect(collection_resources_service).to have_received(:upload_collection_resource).with("2024_25_lettings_paper_form.pdf", anything)
      expect(page).to have_content("The lettings 2024 to 2025 paper form has been updated")
    end

    it "only allows pdf files for sales" do
      visit("/collection-resources/sales/2024/paper_form/edit")

      click_button("Save changes")

      expect(page).to have_content("Select which file to upload")

      expect(page).to have_content("Change the paper form")
      expect(page).to have_content("Sales 2024 to 2025")

      attach_file "file", file_fixture("excel_file.xlsx")
      click_button("Save changes")

      expect(page).to have_content("The paper form must be a PDF.")

      attach_file "file", file_fixture("pdf_file.pdf")
      click_button("Save changes")

      expect(page).not_to have_content("The paper form must be a PDF.")
      expect(collection_resources_service).to have_received(:upload_collection_resource).with("2024_25_sales_paper_form.pdf", anything)
      expect(page).to have_content("The sales 2024 to 2025 paper form has been updated")
    end
  end

  context "when uploading bu template" do
    it "only allows excel files for lettings" do
      visit("/collection-resources/lettings/2024/bulk_upload_template/edit")

      click_button("Save changes")

      expect(page).to have_content("Select which file to upload")

      expect(page).to have_content("Change the bulk upload template")
      expect(page).to have_content("Lettings 2024 to 2025")

      attach_file "file", file_fixture("pdf_file.pdf")
      click_button("Save changes")

      expect(page).to have_content("The bulk upload template must be a Microsoft Excel file.")

      attach_file "file", file_fixture("excel_file.xlsx")
      click_button("Save changes")

      expect(page).not_to have_content("The bulk upload template must be a Microsoft Excel file.")
      expect(collection_resources_service).to have_received(:upload_collection_resource).with("bulk-upload-lettings-template-2024-25.xlsx", anything)
      expect(page).to have_content("The lettings 2024 to 2025 bulk upload template has been updated")
    end

    it "only allows excel files for sales" do
      visit("/collection-resources/sales/2024/bulk_upload_template/edit")

      click_button("Save changes")

      expect(page).to have_content("Select which file to upload")

      expect(page).to have_content("Change the bulk upload template")
      expect(page).to have_content("Sales 2024 to 2025")

      attach_file "file", file_fixture("pdf_file.pdf")
      click_button("Save changes")

      expect(page).to have_content("The bulk upload template must be a Microsoft Excel file.")

      attach_file "file", file_fixture("excel_file.xlsx")
      click_button("Save changes")

      expect(page).not_to have_content("The bulk upload template must be a Microsoft Excel file.")
      expect(collection_resources_service).to have_received(:upload_collection_resource).with("bulk-upload-sales-template-2024-25.xlsx", anything)
      expect(page).to have_content("The sales 2024 to 2025 bulk upload template has been updated")
    end
  end

  context "when uploading bu specification" do
    it "only allows excel files for lettings" do
      visit("/collection-resources/lettings/2024/bulk_upload_specification/edit")

      click_button("Save changes")

      expect(page).to have_content("Select which file to upload")

      expect(page).to have_content("Change the bulk upload specification")
      expect(page).to have_content("Lettings 2024 to 2025")

      attach_file "file", file_fixture("pdf_file.pdf")
      click_button("Save changes")

      expect(page).to have_content("The bulk upload specification must be a Microsoft Excel file.")

      attach_file "file", file_fixture("excel_file.xlsx")
      click_button("Save changes")

      expect(page).not_to have_content("The bulk upload specification must be a Microsoft Excel file.")
      expect(collection_resources_service).to have_received(:upload_collection_resource).with("bulk-upload-lettings-specification-2024-25.xlsx", anything)
      expect(page).to have_content("The lettings 2024 to 2025 bulk upload specification has been updated")
    end

    it "only allows excel files for sales" do
      visit("/collection-resources/sales/2024/bulk_upload_specification/edit")

      click_button("Save changes")

      expect(page).to have_content("Select which file to upload")

      expect(page).to have_content("Change the bulk upload specification")
      expect(page).to have_content("Sales 2024 to 2025")

      attach_file "file", file_fixture("pdf_file.pdf")
      click_button("Save changes")

      expect(page).to have_content("The bulk upload specification must be a Microsoft Excel file.")

      attach_file "file", file_fixture("excel_file.xlsx")
      click_button("Save changes")

      expect(page).not_to have_content("The bulk upload specification must be a Microsoft Excel file.")
      expect(collection_resources_service).to have_received(:upload_collection_resource).with("bulk-upload-sales-specification-2024-25.xlsx", anything)
      expect(page).to have_content("The sales 2024 to 2025 bulk upload specification has been updated")
    end

    it "displays error message if the upload fails" do
      allow(collection_resources_service).to receive(:upload_collection_resource).and_raise(StandardError)

      visit("/collection-resources/sales/2024/bulk_upload_specification/edit")
      attach_file "file", file_fixture("excel_file.xlsx")
      click_button("Save changes")

      expect(page).to have_content("There was an error uploading this file.")
    end
  end
end
