require "rails_helper"

RSpec.describe Forms::BulkUploadForm::Guidance do
  include Rails.application.routes.url_helpers

  subject(:bu_guidance) { described_class.new(year:, referrer:, log_type:) }

  let(:year) { 2024 }
  let(:log_type) { "sales" }
  let(:referrer) { nil }

  describe "sales" do
    describe "#back_path" do
      context "when referrer is prepare-your-file" do
        let(:referrer) { "prepare-your-file" }

        it "returns the prepare your file path" do
          expect(bu_guidance.back_path).to eq bulk_upload_sales_log_path(id: "prepare-your-file", form: { year: })
        end
      end

      context "when referrer is home" do
        let(:referrer) { "home" }

        it "returns the root path" do
          expect(bu_guidance.back_path).to eq root_path
        end
      end

      context "when referrer is guidance" do
        let(:referrer) { "guidance" }

        it "returns the main guidance page path" do
          expect(bu_guidance.back_path).to eq guidance_path
        end
      end

      context "when referrer is absent" do
        let(:referrer) { nil }

        it "returns the main guidance page path" do
          expect(bu_guidance.back_path).to eq guidance_path
        end
      end
    end

    describe "year" do
      context "when year is not provided" do
        let(:year) { nil }

        before do
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(CollectionTimeHelper).to receive(:current_collection_start_year).and_return(2030)
          # rubocop:enable RSpec/AnyInstance
        end

        it "is set to the current collection start year" do
          expect(bu_guidance.year).to eq(2030)
        end
      end
    end
  end

  describe "lettings" do
    let(:log_type) { "lettings" }

    describe "#back_path" do
      context "when referrer is prepare-your-file" do
        let(:referrer) { "prepare-your-file" }

        it "returns the prepare your file path" do
          expect(bu_guidance.back_path).to eq bulk_upload_lettings_log_path(id: "prepare-your-file", form: { year: })
        end
      end

      context "when referrer is home" do
        let(:referrer) { "home" }

        it "returns the root path" do
          expect(bu_guidance.back_path).to eq root_path
        end
      end

      context "when referrer is guidance" do
        let(:referrer) { "guidance" }

        it "returns the main guidance page path" do
          expect(bu_guidance.back_path).to eq guidance_path
        end
      end

      context "when referrer is absent" do
        let(:referrer) { nil }

        it "returns the main guidance page path" do
          expect(bu_guidance.back_path).to eq guidance_path
        end
      end
    end

    describe "year" do
      context "when year is not provided" do
        let(:year) { nil }

        before do
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(CollectionTimeHelper).to receive(:current_collection_start_year).and_return(2030)
          # rubocop:enable RSpec/AnyInstance
        end

        it "is set to the current collection start year" do
          expect(bu_guidance.year).to eq(2030)
        end
      end
    end
  end
end
