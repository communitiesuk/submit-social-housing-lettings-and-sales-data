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

  describe "#editable_collection_resource_years" do
    context "when in crossover period" do
      before do
        allow(FormHandler.instance).to receive(:in_edit_crossover_period?).and_return(true)
        allow(Time.zone).to receive(:today).and_return(Time.zone.local(2024, 4, 8))
      end

      it "returns previous and current years" do
        expect(editable_collection_resource_years).to eq([2023, 2024])
      end
    end

    context "when not in crossover period" do
      before do
        allow(FormHandler.instance).to receive(:in_edit_crossover_period?).and_return(false)
      end

      context "and after 1st January" do
        before do
          allow(Time.zone).to receive(:today).and_return(Time.zone.local(2025, 2, 1))
        end

        it "returns current and next years" do
          expect(editable_collection_resource_years).to match_array([2024, 2025])
        end
      end

      context "and before 1st January" do
        before do
          allow(Time.zone).to receive(:today).and_return(Time.zone.local(2024, 12, 1))
        end

        it "returns current year" do
          expect(editable_collection_resource_years).to eq([2024])
        end
      end
    end
  end

  describe "#displayed_collection_resource_years" do
    context "when in crossover period" do
      before do
        allow(FormHandler.instance).to receive(:in_edit_crossover_period?).and_return(true)
        allow(Time.zone).to receive(:today).and_return(Time.zone.local(2024, 4, 8))
      end

      it "returns previous and current years" do
        expect(displayed_collection_resource_years).to eq([2023, 2024])
      end
    end

    context "when not in crossover period" do
      before do
        allow(FormHandler.instance).to receive(:in_edit_crossover_period?).and_return(false)
      end

      it "returns current year" do
        expect(displayed_collection_resource_years).to eq([2024])
      end

      context "and next year resources were manually released" do
        before do
          CollectionResource.create!(year: 2025, resource_type: "paper_form", display_name: "lettings log for tenants (2025 to 2026)", download_filename: "file.pdf", mandatory: true, released_to_user: true)
          CollectionResource.create!(year: 2025, resource_type: "bulk_upload_template", display_name: "bulk upload template (2025 to 2026)", download_filename: "file.xlsx", mandatory: true, released_to_user: true)
          CollectionResource.create!(year: 2025, resource_type: "bulk_upload_specification", display_name: "sales log for tenants (2025 to 2026)", download_filename: "file.xlsx", mandatory: true, released_to_user: true)
        end

        it "reutrns current and next years" do
          expect(displayed_collection_resource_years).to eq([2024, 2025])
        end
      end
    end
  end

  describe "#year_range_format" do
    it "returns formatted year range" do
      expect(year_range_format(2023)).to eq("23/24")
    end
  end

  describe "#text_year_range_format" do
    it "returns formatted text year range" do
      expect(text_year_range_format(2023)).to eq("2023 to 2024")
    end
  end

  describe "#document_list_component_items" do
    let(:resources) do
      [
        build(:collection_resource, year: 2023, resource_type: "paper_form", display_name: "lettings log for tenants (2023 to 2024)", download_filename: "2023_24_lettings_paper_form.pdf"),
        build(:collection_resource, year: 2023, resource_type: "bulk_upload_template", display_name: "bulk upload template (2023 to 2024)", download_filename: "2023_24_lettings_bulk_upload_template.xlsx"),
      ]
    end

    before do
      allow(storage_service).to receive(:get_file_metadata).with("2023_24_lettings_paper_form.pdf").and_return("content_length" => 292_864, "content_type" => "application/pdf")
      allow(storage_service).to receive(:get_file_metadata).with("2023_24_lettings_bulk_upload_template.xlsx").and_return("content_length" => 19_456, "content_type" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    end

    it "returns component items" do
      expect(document_list_component_items(resources)).to eq([
        {
          name: "Download the lettings log for tenants (2023 to 2024)",
          href: "/collection-resources/lettings/2023/paper_form/download",
          metadata: "PDF, 286 KB",
        },
        {
          name: "Download the bulk upload template (2023 to 2024)",
          href: "/collection-resources/lettings/2023/bulk_upload_template/download",
          metadata: "Microsoft Excel, 19 KB",
        },
      ])
    end
  end

  describe "#document_list_edit_component_items" do
    let(:resources) do
      [
        build(:collection_resource, year: 2023, resource_type: "paper_form", display_name: "lettings log for tenants (2023 to 2024)", download_filename: "2023_24_lettings_paper_form.pdf"),
        build(:collection_resource, year: 2023, resource_type: "bulk_upload_template", display_name: "bulk upload template (2023 to 2024)", download_filename: "2023_24_lettings_bulk_upload_template.xlsx"),
      ]
    end

    before do
      allow(storage_service).to receive(:get_file_metadata).with("2023_24_lettings_paper_form.pdf").and_return("content_length" => 292_864, "content_type" => "application/pdf")
      allow(storage_service).to receive(:get_file_metadata).with("2023_24_lettings_bulk_upload_template.xlsx").and_return("content_length" => 19_456, "content_type" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    end

    it "returns component items" do
      expect(document_list_edit_component_items(resources)).to eq([
        {
          name: "2023_24_lettings_paper_form.pdf",
          href: "/collection-resources/lettings/2023/paper_form/download",
          metadata: "PDF, 286 KB",
        },
        {
          name: "2023_24_lettings_bulk_upload_template.xlsx",
          href: "/collection-resources/lettings/2023/bulk_upload_template/download",
          metadata: "Microsoft Excel, 19 KB",
        },
      ])
    end
  end

  describe "#display_next_year_banner?" do
    context "when next year is not editable" do
      before do
        allow(FormHandler.instance).to receive(:in_edit_crossover_period?).and_return(true)
      end

      it "returns false" do
        expect(display_next_year_banner?).to be_falsey
      end
    end

    context "when next year is editable" do
      before do
        allow(FormHandler.instance).to receive(:in_edit_crossover_period?).and_return(false)
        allow(Time.zone).to receive(:today).and_return(Time.zone.local(2025, 1, 1))
      end

      it "returns true" do
        expect(display_next_year_banner?).to be_truthy
      end

      context "and the resources have been manually released" do
        before do
          CollectionResource.create!(year: 2025, resource_type: "paper_form", display_name: "lettings log for tenants (2025 to 2026)", download_filename: "file.pdf", mandatory: true, released_to_user: true)
          CollectionResource.create!(year: 2025, resource_type: "bulk_upload_template", display_name: "bulk upload template (2025 to 2026)", download_filename: "file.xlsx", mandatory: true, released_to_user: true)
          CollectionResource.create!(year: 2025, resource_type: "bulk_upload_specification", display_name: "sales log for tenants (2025 to 2026)", download_filename: "file.xlsx", mandatory: true, released_to_user: true)
        end

        it "returns false" do
          expect(display_next_year_banner?).to be_falsey
        end
      end
    end
  end

  describe "#next_year_banner_text" do
    let(:lettings_resources) { MandatoryCollectionResourcesService.generate_resources("lettings", [next_collection_start_year]) }
    let(:sales_resources) { MandatoryCollectionResourcesService.generate_resources("sales", [next_collection_start_year]) }

    context "when all the mandatory resources for next year are uploaded" do
      before do
        allow(storage_service).to receive(:file_exists?).and_return(true)
      end

      it "returns correct text" do
        expect(next_year_banner_text(lettings_resources, sales_resources)).to match(/Release the 2025 to 2026 collection resources to users/)
      end
    end

    context "when some of the mandatory resources for next year are not uploaded" do
      before do
        allow(storage_service).to receive(:file_exists?).and_return(false)
      end

      it "returns correct text" do
        expect(next_year_banner_text(lettings_resources, sales_resources)).to eq("Once you have uploaded all the required 2025 to 2026 collection resources, you will be able to release them to users.")
      end
    end
  end
end
