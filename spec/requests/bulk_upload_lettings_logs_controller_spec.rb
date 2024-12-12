require "rails_helper"

RSpec.describe BulkUploadLettingsLogsController, type: :request do
  include CollectionTimeHelper

  let(:user) { create(:user) }
  let(:organisation) { user.organisation }

  before do
    sign_in user
  end

  describe "GET /lettings-logs/bulk-upload-logs/start" do
    context "when data protection confirmation not signed" do
      let(:organisation) { create(:organisation, :without_dpc) }
      let(:user) { create(:user, organisation:, with_dsa: false) }

      it "redirects to lettings index page" do
        get "/lettings-logs/bulk-upload-logs/start", params: {}

        expect(response).to redirect_to("/lettings-logs")
      end
    end

    context "when not in crossover period" do
      let(:expected_year) { current_collection_start_year }

      before do
        allow(FormHandler.instance).to receive(:lettings_in_crossover_period?).and_return(false)
      end

      it "redirects to /prepare-your-file" do
        get "/lettings-logs/bulk-upload-logs/start", params: {}

        expect(response).to redirect_to("/lettings-logs/bulk-upload-logs/prepare-your-file?form%5Byear%5D=#{expected_year}")
      end
    end

    context "when in crossover period" do
      before do
        allow(FormHandler.instance).to receive(:lettings_in_crossover_period?).and_return(true)
      end

      it "redirects to /year" do
        get "/lettings-logs/bulk-upload-logs/start", params: {}

        expect(response).to redirect_to("/lettings-logs/bulk-upload-logs/year")
      end
    end
  end

  describe "GET /lettings-logs/bulk-upload-logs/guidance" do
    context "when not in crossover period" do
      before do
        allow(FormHandler.instance).to receive(:lettings_in_crossover_period?).and_return(false)
      end

      it "shows guidance page with correct title" do
        get "/lettings-logs/bulk-upload-logs/guidance?form%5Byear%5D=#{current_collection_start_year}", params: {}

        expect(response.body).to include("How to upload logs in bulk")
      end
    end

    context "when in crossover period" do
      before do
        allow(FormHandler.instance).to receive(:lettings_in_crossover_period?).and_return(true)
      end

      it "shows guidance page with correct title" do
        get "/lettings-logs/bulk-upload-logs/guidance?form%5Byear%5D=#{current_collection_start_year}", params: {}

        expect(response.body).to include("How to upload logs in bulk")
      end
    end

    context "when no year is specified" do
      it "shows guidance page with links defaulting to the current year" do
        get "/lettings-logs/bulk-upload-logs/guidance"

        expect(response.body).to include("Download the lettings bulk upload template (#{current_collection_start_year} to #{current_collection_start_year + 1})")
      end
    end

    context "when an invalid year is specified" do
      it "shows not found" do
        get "/lettings-logs/bulk-upload-logs/guidance?form%5Byear%5D=10000"

        expect(response).to be_not_found
      end
    end
  end

  describe "GET /lettings-logs/bulk-upload-logs/year" do
    it "does not require a year to be specified" do
      get "/lettings-logs/bulk-upload-logs/year"

      expect(response).to be_ok
    end
  end

  pages_requiring_year_specification = %w[prepare-your-file upload-your-file checking-file]
  pages_requiring_year_specification.each do |page_id|
    describe "GET /lettings-logs/bulk-upload-logs/#{page_id}" do
      context "when no year is provided" do
        it "returns not found" do
          get "/lettings-logs/bulk-upload-logs/#{page_id}"

          expect(response).to be_not_found
        end
      end

      context "when requesting the previous year in a crossover period" do
        before do
          allow(FormHandler.instance).to receive(:lettings_in_crossover_period?).and_return(true)
        end

        it "succeeds" do
          get "/lettings-logs/bulk-upload-logs/#{page_id}?form%5Byear%5D=#{current_collection_start_year - 1}"

          expect(response).to be_ok
        end
      end

      context "when requesting the previous year outside a crossover period" do
        before do
          allow(FormHandler.instance).to receive(:lettings_in_crossover_period?).and_return(false)
        end

        it "returns not found" do
          get "/lettings-logs/bulk-upload-logs/#{page_id}?form%5Byear%5D=#{current_collection_start_year - 1}"

          expect(response).to be_not_found
        end
      end

      context "when requesting the current year" do
        it "succeeds" do
          get "/lettings-logs/bulk-upload-logs/#{page_id}?form%5Byear%5D=#{current_collection_start_year}"

          expect(response).to be_ok
        end
      end

      if page_id != "prepare-your-file"
        context "when requesting the next year with future form use toggled on" do
          before do
            allow(FeatureToggle).to receive(:allow_future_form_use?).and_return(true)
          end

          it "succeeds" do
            get "/lettings-logs/bulk-upload-logs/#{page_id}?form%5Byear%5D=#{current_collection_start_year + 1}"

            expect(response).to be_ok
          end
        end
      end

      context "when requesting the next year with future form use toggled off" do
        before do
          allow(FeatureToggle).to receive(:allow_future_form_use?).and_return(false)
        end

        it "returns not found" do
          get "/lettings-logs/bulk-upload-logs/#{page_id}?form%5Byear%5D=#{current_collection_start_year + 1}"

          expect(response).to be_not_found
        end
      end

      context "when requesting a far future year" do
        it "returns not found" do
          get "/lettings-logs/bulk-upload-logs/#{page_id}?form%5Byear%5D=9990"

          expect(response).to be_not_found
        end
      end

      context "when requesting a nonsense value for year" do
        it "returns not found" do
          get "/lettings-logs/bulk-upload-logs/#{page_id}?form%5Byear%5D=thisisnotayear"

          expect(response).to be_not_found
        end
      end
    end
  end
end
