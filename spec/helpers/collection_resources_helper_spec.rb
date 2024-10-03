require "rails_helper"

RSpec.describe CollectionResourcesHelper do
  let(:current_user) { create(:user, :data_coordinator) }
  let(:user) { create(:user, :data_coordinator) }

  describe "when displaying file metadata" do
    context "with pages" do
      before do
        stub_request(:head, "https://core-test-collection-resources.s3.amazonaws.com/2023_24_lettings_paper_form.pdf")
          .to_return(status: 200, body: "", headers: { "Content-Length" => 292_864, "Content-Type" => "application/pdf" })
      end

      it "returns correct metadata" do
        expect(file_type_size_and_pages("2023_24_lettings_paper_form.pdf", number_of_pages: 8)).to eq("PDF, 286 KB, 8 pages")
      end
    end

    context "without pages" do
      before do
        stub_request(:head, "https://core-test-collection-resources.s3.amazonaws.com/bulk-upload-lettings-template-2023-24.xlsx")
          .to_return(status: 200, body: "", headers: { "Content-Length" => 19_456, "Content-Type" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" })
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
          expect(editable_collection_resource_years).to eq([2024, 2025])
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

  describe "#underscored_file_year_format" do
    it "returns formatted dasherised file year" do
      expect(underscored_file_year_format(2023)).to eq("2023_24")
    end
  end

  describe "#dasherised_file_year_format" do
    it "returns formatted dasherised file year" do
      expect(dasherised_file_year_format(2023)).to eq("2023-24")
    end
  end

  describe "#short_underscored_year_range_format" do
    it "returns formatted short underscored year range" do
      expect(short_underscored_year_range_format(2023)).to eq("23_24")
    end
  end
end
