require "rails_helper"

RSpec.describe CollectionResourcesHelper do
  let(:current_user) { create(:user, :data_coordinator) }
  let(:user) { create(:user, :data_coordinator) }
  let(:storage_service) { instance_double(Storage::S3Service, get_file_metadata: nil) }

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:configuration).and_return(OpenStruct.new(bucket_name: "core-test-collection-resources"))
  end

  describe "when displaying file metadata" do
    context "with pages" do
      before do
        allow(storage_service).to receive(:get_file_metadata).with("2023_24_lettings_paper_form.pdf").and_return("content_length" => 292_864, "content_type" => "application/pdf")
      end

      it "returns correct metadata" do
        expect(file_type_size_and_pages("2023_24_lettings_paper_form.pdf", number_of_pages: 8)).to eq("PDF, 286 KB, 8 pages")
      end
    end

    context "without pages" do
      before do
        allow(storage_service).to receive(:get_file_metadata).with("bulk-upload-lettings-template-2023-24.xlsx").and_return("content_length" => 19_456, "content_type" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      end

      it "returns correct metadata" do
        expect(file_type_size_and_pages("bulk-upload-lettings-template-2023-24.xlsx")).to eq("Microsoft Excel, 19 KB")
      end
    end
  end
end
