require "rails_helper"

RSpec.describe Imports::LettingsLogsImportProcessor do
  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:logger) { instance_double(ActiveSupport::Logger) }

  let(:real_2021_2022_form) { Form.new("config/forms/2021_2022.json") }
  let(:real_2022_2023_form) { Form.new("config/forms/2022_2023.json") }
  let(:fixture_directory) { "spec/fixtures/imports/logs" }

  let(:organisation) { FactoryBot.create(:organisation, old_visible_id: "1", provider_type: "PRP") }
  let(:scheme1) { FactoryBot.create(:scheme, old_visible_id: 123, owning_organisation: organisation) }
  let(:scheme2) { FactoryBot.create(:scheme, old_visible_id: 456, owning_organisation: organisation) }

  def open_file(directory, filename)
    File.open("#{directory}/#{filename}.xml")
  end

  before do
    WebMock.stub_request(:get, /api.postcodes.io\/postcodes\/LS166FT/)
           .to_return(status: 200, body: '{"status":200,"result":{"admin_district":"Westminster","codes":{"admin_district":"E08000035"}}}', headers: {})

    allow(Organisation).to receive(:find_by).and_return(nil)
    allow(Organisation).to receive(:find_by).with(old_visible_id: organisation.old_visible_id.to_i).and_return(organisation)

    # Created by users
    FactoryBot.create(:user, old_user_id: "c3061a2e6ea0b702e6f6210d5c52d2a92612d2aa", organisation:)
    FactoryBot.create(:user, old_user_id: "e29c492473446dca4d50224f2bb7cf965a261d6f", organisation:)

    # Location setup
    FactoryBot.create(:location, old_visible_id: 10, postcode: "LS166FT", scheme_id: scheme1.id, mobility_type: "W")
    FactoryBot.create(:location, scheme_id: scheme1.id)
    FactoryBot.create(:location, old_visible_id: 10, postcode: "LS166FT", scheme_id: scheme2.id, mobility_type: "W")

    # Stub the form handler to use the real form
    allow(FormHandler.instance).to receive(:get_form).with("previous_lettings").and_return(real_2021_2022_form)
    allow(FormHandler.instance).to receive(:get_form).with("current_lettings").and_return(real_2022_2023_form)
  end

  let(:lettings_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }
  let(:lettings_log_file) { open_file(fixture_directory, lettings_log_id) }
  let(:lettings_log_xml) { Nokogiri::XML(lettings_log_file) }

  describe '#initialize' do
    context "with valid params" do
      it "sets document-id as old_id" do
        import = Imports::LettingsLogsImportProcessor.new(lettings_log_xml.to_s, logger)

        expect(import.old_id).to eq "0ead17cb-1668-442d-898c-0d52879ff592"
      end
    end

    context "when the void date is after the start date" do
      before { lettings_log_xml.at_xpath("//xmlns:VYEAR").content = 2023 }

      it "does not import the voiddate" do
        expect(logger).to receive(:warn).with(/is not completed/).once
        expect(logger).to receive(:warn).with(/lettings log with old id:#{lettings_log_id} is incomplete but status should be complete/).once

        import = Imports::LettingsLogsImportProcessor.new(lettings_log_xml.to_s, logger)

        lettings_log = LettingsLog.where(old_id: lettings_log_id).first
        expect(lettings_log&.voiddate).to be_nil
        expect(import.discrepancy).to be true
      end
    end

    context "when the organisation legacy ID does not exist" do
      before { lettings_log_xml.at_xpath("//xmlns:OWNINGORGID").content = 99_999 }

      it "raises an exception" do
        expect { Imports::LettingsLogsImportProcessor.new(lettings_log_xml.to_s, logger) }
          .to raise_error(RuntimeError, "Organisation not found with legacy ID 99999")
      end
    end

    context "when a person is under 16" do
      before { lettings_log_xml.at_xpath("//xmlns:P2Age").content = 14 }

      context "when the economic status is set to refuse" do
        before { lettings_log_xml.at_xpath("//xmlns:P2Eco").content = "10) Refused" }

        it "sets the economic status to child under 16" do
          # The update is done when calculating derived variables
          expect(logger).to receive(:warn).with(/Differences found when saving log/)
          Imports::LettingsLogsImportProcessor.new(lettings_log_xml.to_s, logger)

          lettings_log = LettingsLog.where(old_id: lettings_log_id).first
          expect(lettings_log&.ecstat2).to be(9)
        end
      end

      context "when the relationship to lead tenant is set to refuse" do
        before { lettings_log_xml.at_xpath("//xmlns:P2Rel").content = "Refused" }

        it "sets the relationship to lead tenant to child" do
          Imports::LettingsLogsImportProcessor.new(lettings_log_xml.to_s, logger)

          lettings_log = LettingsLog.where(old_id: lettings_log_id).first
          expect(lettings_log&.relat2).to eq("C")
        end
      end
    end

    context "when this is an internal transfer from a non social housing" do
      before do
        lettings_log_xml.at_xpath("//xmlns:Q11").content = "9 Residential care home"
        lettings_log_xml.at_xpath("//xmlns:Q16").content = "1 Internal Transfer"
      end

      it "intercepts the relevant validation error" do
        expect(logger).to receive(:warn).with(/Removing internal transfer referral since previous tenancy is a non social housing/)
        expect { Imports::LettingsLogsImportProcessor.new(lettings_log_xml.to_s, logger) }
          .not_to raise_error
      end

      it "clears out the referral answer" do
        allow(logger).to receive(:warn)

        Imports::LettingsLogsImportProcessor.new(lettings_log_xml.to_s, logger)
        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

        expect(lettings_log).not_to be_nil
        expect(lettings_log.referral).to be_nil
      end

      context "and this is an internal transfer from a previous fixed term tenancy" do
        before do
          lettings_log_xml.at_xpath("//xmlns:Q11").content = "30 Fixed term Local Authority General Needs tenancy"
          lettings_log_xml.at_xpath("//xmlns:Q16").content = "1 Internal Transfer"
        end

        it "intercepts the relevant validation error" do
          expect(logger).to receive(:warn).with(/Removing internal transfer referral since previous tenancy is fixed terms or lifetime/)
          expect { Imports::LettingsLogsImportProcessor.new(lettings_log_xml.to_s, logger) }
            .not_to raise_error
        end

        it "clears out the referral answer" do
          allow(logger).to receive(:warn)

          Imports::LettingsLogsImportProcessor.new(lettings_log_xml.to_s, logger)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.referral).to be_nil
        end
      end
    end

    context "when the net income soft validation is triggered (net_income_value_check)" do
      before do
        lettings_log_xml.at_xpath("//xmlns:Q8a").content = "1 Weekly"
        lettings_log_xml.at_xpath("//xmlns:Q8Money").content = 890.00
      end

      it "completes the log" do
        Imports::LettingsLogsImportProcessor.new(lettings_log_xml.to_s, logger)
        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)
        expect(lettings_log.status).to eq("completed")
      end
    end

    context "when the rent soft validation is triggered (rent_value_check)" do
      before do
        lettings_log_xml.at_xpath("//xmlns:Q18ai").content = 200.00
        lettings_log_xml.at_xpath("//xmlns:Q18av").content = 232.02
        lettings_log_xml.at_xpath("//xmlns:Q17").content = "1 Weekly for 52 weeks"
        LaRentRange.create!(
          start_year: 2021,
          la: "E08000035",
          beds: 2,
          lettype: 1,
          soft_max: 900,
          hard_max: 1500,
          soft_min: 500,
          hard_min: 100,
        )
      end

      it "completes the log" do
        Imports::LettingsLogsImportProcessor.new(lettings_log_xml.to_s, logger)
        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)
        expect(lettings_log.status).to eq("completed")
      end
    end

    context "when the retirement soft validation is triggered (retirement_value_check)" do
      before do
        lettings_log_xml.at_xpath("//xmlns:P1Age").content = 68
        lettings_log_xml.at_xpath("//xmlns:P1Eco").content = "6) Not Seeking Work"
      end

      it "completes the log" do
        Imports::LettingsLogsImportProcessor.new(lettings_log_xml.to_s, logger)
        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)
        expect(lettings_log.status).to eq("completed")
      end
    end

    context "when this is a supported housing log with multiple locations under a scheme" do
      let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

      it "sets the scheme and location values" do
        expect(logger).not_to receive(:warn)
        Imports::LettingsLogsImportProcessor.new(lettings_log_xml.to_s, logger)
        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

        expect(lettings_log.scheme_id).not_to be_nil
        expect(lettings_log.location_id).not_to be_nil
        expect(lettings_log.status).to eq("completed")
      end
    end

    context "when this is a supported housing log with a single location under a scheme" do
      let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

      before { lettings_log_xml.at_xpath("//xmlns:_1cmangroupcode").content = scheme2.old_visible_id }

      it "sets the scheme and location values" do
        expect(logger).not_to receive(:warn)
        Imports::LettingsLogsImportProcessor.new(lettings_log_xml.to_s, logger)
        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

        expect(lettings_log.scheme_id).not_to be_nil
        expect(lettings_log.location_id).not_to be_nil
        expect(lettings_log.status).to eq("completed")
      end
    end
  end
end
