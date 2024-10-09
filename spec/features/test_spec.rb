require "rails_helper"
RSpec.describe "Test Features" do
  let(:storage_service) { instance_double(Storage::S3Service, get_file_metadata: nil) }

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:configuration).and_return(OpenStruct.new(bucket_name: "core-test-collection-resources"))
  end

  it "Displays the name of the app" do
    visit(root_path)
    expect(page).to have_content("Submit social housing lettings and sales data (CORE)")
  end

  it "Responds to a health check" do
    visit("/health")
    expect(page).to have_http_status(:no_content)
  end
end
