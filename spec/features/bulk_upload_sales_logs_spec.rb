require "rails_helper"

RSpec.describe "Bulk upload sales log" do
  let(:user) { create(:user) }

  let(:stub_file_upload) do
    vcap_services = { "aws-s3-bucket" => {} }
    mock_storage_service = instance_double("S3Service")

    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return(vcap_services.to_json)

    allow(Storage::S3Service).to receive(:new).and_return(mock_storage_service)
    allow(mock_storage_service).to receive(:write_file)
  end

  before do
    stub_file_upload
    sign_in user
  end

  # rubocop:disable RSpec/AnyInstance
  context "when during crossover period" do
    before do
      Timecop.freeze(2024, 5, 1)
    end

    after do
      Timecop.return
    end

    it "shows journey with year option" do
      visit("/sales-logs")
      expect(page).to have_link("Upload sales logs in bulk")
      click_link("Upload sales logs in bulk")

      expect(page).to have_content("Which year")
      click_button("Continue")

      expect(page).to have_content("You must select a collection period to upload for")
      choose("2024 to 2025")
      click_button("Continue")

      click_link("Back")

      expect(page.find_field("form-year-2024-field")).to be_checked
      click_button("Continue")

      expect(page).to have_content("Upload sales logs in bulk (2024 to 2025)")
      click_button("Continue")

      expect(page).to have_content("Upload your file")
      click_button("Upload")

      allow_any_instance_of(Forms::BulkUploadForm::UploadYourFile).to receive(:`).and_return("not a csv")

      expect(page).to have_content("Select which file to upload")
      attach_file "file", file_fixture("2023_24_lettings_bulk_upload.xlsx")
      click_button("Upload")

      allow_any_instance_of(Forms::BulkUploadForm::UploadYourFile).to receive(:`).and_return("text/csv")

      expect(page).to have_content("Your file must be in CSV format")
      attach_file "file", file_fixture("blank_bulk_upload_sales.csv")
      expect {
        click_button("Upload")
      }.to change(BulkUpload, :count).by(1)

      expect(page).to have_content("Once this is done")
      click_link("Back")

      expect(page).to have_content("Upload sales logs in bulk")
    end

    it "shows file to large error" do
      stub_const("Forms::BulkUploadForm::UploadYourFile::MAX_FILE_SIZE", 1.bytes)
      visit("/sales-logs")
      click_link("Upload sales logs in bulk")

      expect(page).to have_content("Which year")
      click_button("Continue")
      click_button("Continue")
      choose("2024 to 2025")
      click_button("Continue")
      click_button("Continue")

      allow_any_instance_of(Forms::BulkUploadForm::UploadYourFile).to receive(:`).and_return("text/csv")

      attach_file "file", file_fixture("2023_24_lettings_bulk_upload.xlsx")
      click_button("Upload")

      expect(page).to have_content("File must be 10MB or less. Check your file and delete data that does not need to be uploaded.")
    end
  end
  # rubocop:enable RSpec/AnyInstance

  context "when not in crossover period" do
    before do
      Timecop.freeze(2025, 2, 1)
    end

    after do
      Timecop.return
    end

    it "shows journey without year option" do
      visit("/sales-logs")
      expect(page).to have_link("Upload sales logs in bulk")
      click_link("Upload sales logs in bulk")

      expect(page).to have_content("Upload sales logs in bulk (2024 to 2025)")
      click_button("Continue")

      expect(page).to have_content("Upload your file")
    end
  end
end
