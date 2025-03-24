require "rails_helper"

RSpec.describe "Collection resources" do
  let(:user) { create(:user, :support) }
  let(:collection_resources_service) { instance_double(CollectionResourcesService, file_exists_on_s3?: true) }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(CollectionResourcesHelper).to receive(:editable_collection_resource_years).and_return([2024, 2025])
    allow_any_instance_of(CollectionResourcesHelper).to receive(:displayed_collection_resource_years).and_return([2024])
    # rubocop:enable RSpec/AnyInstance
    allow(CollectionResourcesService).to receive(:new).and_return(collection_resources_service)
    allow(collection_resources_service).to receive(:upload_collection_resource)
    allow(collection_resources_service).to receive(:get_file_metadata).and_return({ "content_type" => "application/pdf", "content_length" => 1000 })
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

  context "when uploading an additional resource" do
    it "allows valid files" do
      expect(CollectionResource.count).to eq(0)

      visit(new_collection_resource_path(year: 2025, log_type: "sales"))
      fill_in("collection_resource[short_display_name]", with: "some file")
      attach_file "file", file_fixture("pdf_file.pdf")

      click_button("Add resource")
      expect(collection_resources_service).to have_received(:upload_collection_resource).with("pdf_file.pdf", anything)
      expect(CollectionResource.count).to eq(1)
      expect(CollectionResource.first.year).to eq(2025)
      expect(CollectionResource.first.log_type).to eq("sales")
      expect(CollectionResource.first.resource_type).to be_nil
      expect(CollectionResource.first.mandatory).to be_falsey
      expect(CollectionResource.first.released_to_user).to be_nil
      expect(CollectionResource.first.display_name).to eq("sales some file (2025 to 2026)")
      expect(CollectionResource.first.short_display_name).to eq("some file")
      expect(page).to have_content("The sales 2025 to 2026 some file has been uploaded.")
    end

    it "validates file is attached" do
      visit(new_collection_resource_path(year: 2025, log_type: "sales"))

      fill_in("collection_resource[short_display_name]", with: "some file")
      click_button("Add resource")
      expect(page).to have_content("Select which file to upload.")
    end

    it "validates resource type is given" do
      visit(new_collection_resource_path(year: 2025, log_type: "sales"))

      attach_file "file", file_fixture("pdf_file.pdf")
      click_button("Add resource")
      expect(page).to have_content("You must answer resource type.")
    end
  end

  context "when updating an additional resource" do
    let!(:collection_resource) { create(:collection_resource, :additional, year: 2025, log_type: "sales") }

    it "only allows valid files" do
      expect(CollectionResource.count).to eq(1)

      visit(collection_resource_edit_path(collection_resource))
      fill_in("collection_resource[short_display_name]", with: "some updated file")
      attach_file "file", file_fixture("pdf_file.pdf")

      click_button("Save changes")
      expect(collection_resources_service).to have_received(:upload_collection_resource).with("pdf_file.pdf", anything)
      expect(CollectionResource.count).to eq(1)
      expect(CollectionResource.first.year).to eq(2025)
      expect(CollectionResource.first.log_type).to eq("sales")
      expect(CollectionResource.first.resource_type).to be_nil
      expect(CollectionResource.first.mandatory).to be_falsey
      expect(CollectionResource.first.released_to_user).to be_nil
      expect(CollectionResource.first.display_name).to eq("sales some updated file (2025 to 2026)")
      expect(CollectionResource.first.short_display_name).to eq("some updated file")
      expect(page).to have_content("The sales 2025 to 2026 some updated file has been updated.")
    end

    it "validates file is attached" do
      visit(collection_resource_edit_path(collection_resource))

      fill_in("collection_resource[short_display_name]", with: "some file")
      click_button("Save changes")
      expect(page).to have_content("Select which file to upload.")
    end
  end
end
