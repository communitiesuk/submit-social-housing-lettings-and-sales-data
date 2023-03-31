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
    it "shows journey with year option" do
      Timecop.freeze(2023, 5, 1) do
        visit("/sales-logs")
        expect(page).to have_link("Upload sales logs in bulk")
        click_link("Upload sales logs in bulk")

        expect(page).to have_content("Which year")
        click_button("Continue")

        expect(page).to have_content("You must select a collection period to upload for")
        choose("2022/2023")
        click_button("Continue")

        click_link("Back")

        expect(page.find_field("form-year-2022-field")).to be_checked
        click_button("Continue")

        expect(page).to have_content("Upload sales logs in bulk (2022/23)")
        click_button("Continue")

        expect(page).to have_content("Upload your file")
        click_button("Upload")

        allow_any_instance_of(Forms::BulkUploadSales::UploadYourFile).to receive(:`).and_return("not a csv")

        expect(page).to have_content("Select which file to upload")
        attach_file "file", file_fixture("2021_22_lettings_bulk_upload.xlsx")
        click_button("Upload")

        allow_any_instance_of(Forms::BulkUploadSales::UploadYourFile).to receive(:`).and_return("text/csv")

        expect(page).to have_content("Your file must be in CSV format")
        attach_file "file", file_fixture("blank_bulk_upload_sales.csv")
        expect {
          click_button("Upload")
        }.to change(BulkUpload, :count).by(1)

        expect(page).to have_content("Once this is done")
        click_link("Back")

        expect(page).to have_content("Upload sales logs in bulk")
      end
    end
  end
  # rubocop:enable RSpec/AnyInstance

  context "when not it crossover period" do
    xit "shows journey with year option" do
      Timecop.freeze(2023, 10, 1) do
        visit("/sales-logs")
        expect(page).to have_link("Upload sales logs in bulk")
        click_link("Upload sales logs in bulk")

        expect(page).to have_content("Upload sales logs in bulk (2023/24)")
        click_button("Continue")

        expect(page).to have_content("Upload your file")
      end
    end
  end
end
