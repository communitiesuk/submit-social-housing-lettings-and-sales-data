require "rails_helper"

RSpec.describe Imports::LettingsLogsImportService do
  context "with 21/22 logs" do
    subject(:lettings_log_service) { described_class.new(storage_service, logger) }

    around do |example|
      Timecop.freeze(Time.zone.local(2022, 1, 1)) do
        Singleton.__init__(FormHandler)
        example.run
      end
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    let(:storage_service) { instance_double(Storage::S3Service) }
    let(:logs_string) { StringIO.new }
    let(:file_logger) { Logger.new(logs_string) }
    let(:logger) { MultiLogger.new(file_logger) }

    let(:real_2021_2022_form) { Form.new("config/forms/2021_2022.json") }
    let(:real_2022_2023_form) { Form.new("config/forms/2022_2023.json") }
    let(:fixture_directory) { "spec/fixtures/imports/logs" }

    let(:organisation) { FactoryBot.create(:organisation, old_visible_id: "1", provider_type: "PRP") }
    let(:managing_organisation) { FactoryBot.create(:organisation, old_visible_id: "2", provider_type: "PRP") }
    let(:scheme1) { FactoryBot.create(:scheme, old_visible_id: "0123", owning_organisation: organisation) }
    let(:scheme2) { FactoryBot.create(:scheme, old_visible_id: "456", owning_organisation: organisation) }

    def open_file(directory, filename)
      File.open("#{directory}/#{filename}.xml")
    end

    before do
      WebMock.stub_request(:get, /api.postcodes.io\/postcodes\/LS166FT/)
             .to_return(status: 200, body: '{"status":200,"result":{"admin_district":"Westminster","codes":{"admin_district":"E08000035"}}}', headers: {})

      allow(Organisation).to receive(:find_by).and_return(nil)
      allow(Organisation).to receive(:find_by).with(old_visible_id: organisation.old_visible_id).and_return(organisation)
      allow(Organisation).to receive(:find_by).with(old_visible_id: managing_organisation.old_visible_id).and_return(managing_organisation)

      # Created by users
      FactoryBot.create(:user, old_user_id: "c3061a2e6ea0b702e6f6210d5c52d2a92612d2aa", organisation:)
      FactoryBot.create(:user, old_user_id: "e29c492473446dca4d50224f2bb7cf965a261d6f", organisation:)

      # Location setup
      FactoryBot.create(:location, old_visible_id: "10", postcode: "LS166FT", scheme_id: scheme1.id, mobility_type: "W", startdate: Time.zone.local(2021, 4, 1))
      FactoryBot.create(:location, scheme_id: scheme1.id, startdate: Time.zone.local(2021, 4, 1))
      FactoryBot.create(:location, old_visible_id: "10", postcode: "LS166FT", scheme_id: scheme2.id, mobility_type: "W", startdate: Time.zone.local(2021, 4, 1))

      # Stub the form handler to use the real form
      allow(FormHandler.instance).to receive(:get_form).with("current_lettings").and_return(real_2021_2022_form)
      allow(FormHandler.instance).to receive(:get_form).with("previous_lettings").and_return(real_2021_2022_form)
      allow(FormHandler.instance).to receive(:get_form).with("next_lettings").and_return(real_2022_2023_form)
    end

    context "when importing lettings logs" do
      let(:remote_folder) { "lettings_logs" }
      let(:lettings_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }
      let(:lettings_log_id2) { "166fc004-392e-47a8-acb8-1c018734882b" }
      let(:lettings_log_id3) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }
      let(:sales_log) { "shared_ownership_sales_log" }

      before do
        # Stub the S3 file listing and download
        allow(storage_service).to receive(:list_files)
                                    .and_return(%W[#{remote_folder}/#{lettings_log_id}.xml #{remote_folder}/#{lettings_log_id2}.xml #{remote_folder}/#{lettings_log_id3}.xml #{remote_folder}/#{sales_log}.xml])
        allow(storage_service).to receive(:get_file_io)
                                    .with("#{remote_folder}/#{lettings_log_id}.xml")
                                    .and_return(open_file(fixture_directory, lettings_log_id), open_file(fixture_directory, lettings_log_id))
        allow(storage_service).to receive(:get_file_io)
                                    .with("#{remote_folder}/#{lettings_log_id2}.xml")
                                    .and_return(open_file(fixture_directory, lettings_log_id2), open_file(fixture_directory, lettings_log_id2))
        allow(storage_service).to receive(:get_file_io)
                                    .with("#{remote_folder}/#{lettings_log_id3}.xml")
                                    .and_return(open_file(fixture_directory, lettings_log_id3), open_file(fixture_directory, lettings_log_id3))
        allow(storage_service).to receive(:get_file_io)
                                    .with("#{remote_folder}/#{sales_log}.xml")
                                    .and_return(open_file(fixture_directory, sales_log), open_file(fixture_directory, sales_log))
      end

      it "successfully create all lettings logs" do
        expect(logger).not_to receive(:error)
        expect(logger).not_to receive(:warn)
        expect(logger).not_to receive(:info)
        expect { lettings_log_service.create_logs(remote_folder) }
          .to change(LettingsLog, :count).by(3)
      end

      it "does not by default update existing lettings logs" do
        expect(logger).not_to receive(:error)
        expect(logger).not_to receive(:warn)
        expect(logger).not_to receive(:info).with(/Updating lettings log/)

        start_time = Time.current

        expect { 2.times { lettings_log_service.create_logs(remote_folder) } }
        .to change(LettingsLog, :count).by(3)

        end_time = Time.current

        updated_logs = LettingsLog.where(updated_at: start_time..end_time).count
        expect(updated_logs).to eq(0)
      end

      context "with updates allowed" do
        subject(:lettings_log_service) { described_class.new(storage_service, logger, allow_updates: true) }

        it "only updates existing lettings logs" do
          expect(logger).not_to receive(:error)
          expect(logger).not_to receive(:warn)

          start_time = Time.current

          expect { 2.times { lettings_log_service.create_logs(remote_folder) } }
            .to change(LettingsLog, :count).by(3)

          end_time = Time.current

          updated_logs = LettingsLog.where(updated_at: start_time..end_time).count
          expect(updated_logs).to eq(3)
        end
      end

      it "creates organisation relationship once" do
        expect(logger).not_to receive(:error)
        expect(logger).not_to receive(:warn)
        expect { lettings_log_service.create_logs(remote_folder) }
          .to change(OrganisationRelationship, :count).by(1)
      end
    end

    context "when importing a specific log" do
      let(:lettings_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }
      let(:lettings_log_file) { open_file(fixture_directory, lettings_log_id) }
      let(:lettings_log_xml) { Nokogiri::XML(lettings_log_file) }

      context "and the user does not exist" do
        before { lettings_log_xml.at_xpath("//meta:owner-user-id").content = "fake_id" }

        it "creates a new unassigned user" do
          expect(logger).to receive(:error).with("Lettings log '0ead17cb-1668-442d-898c-0d52879ff592' belongs to legacy user with owner-user-id: 'fake_id' which cannot be found. Assigning log to 'Unassigned' user.")
          lettings_log_service.send(:create_log, lettings_log_xml)

          lettings_log = LettingsLog.where(old_id: lettings_log_id).first
          expect(lettings_log&.created_by&.name).to eq("Unassigned")
        end

        it "only creates one unassigned user" do
          expect(logger).to receive(:error).with("Lettings log '0ead17cb-1668-442d-898c-0d52879ff592' belongs to legacy user with owner-user-id: 'fake_id' which cannot be found. Assigning log to 'Unassigned' user.")
          expect(logger).to receive(:error).with("Lettings log 'fake_id' belongs to legacy user with owner-user-id: 'fake_id' which cannot be found. Assigning log to 'Unassigned' user.")
          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log_xml.at_xpath("//meta:document-id").content = "fake_id"
          lettings_log_service.send(:create_log, lettings_log_xml)

          lettings_log = LettingsLog.where(old_id: lettings_log_id).first
          second_lettings_log = LettingsLog.where(old_id: "fake_id").first
          expect(lettings_log&.created_by).to eq(second_lettings_log&.created_by)
        end

        context "when unassigned user exist for a different organisation" do
          let!(:other_unassigned_user) { create(:user, name: "Unassigned") }

          it "creates a new unassigned user for current organisation" do
            expect(logger).to receive(:error).with("Lettings log '0ead17cb-1668-442d-898c-0d52879ff592' belongs to legacy user with owner-user-id: 'fake_id' which cannot be found. Assigning log to 'Unassigned' user.")
            lettings_log_service.send(:create_log, lettings_log_xml)

            lettings_log = LettingsLog.where(old_id: lettings_log_id).first
            expect(lettings_log&.created_by&.name).to eq("Unassigned")
            expect(lettings_log&.created_by).not_to eq(other_unassigned_user)
          end
        end
      end

      context "and the user exists on a different organisation" do
        before do
          create(:legacy_user, old_user_id: "fake_id")
          lettings_log_xml.at_xpath("//meta:owner-user-id").content = "fake_id"
        end

        it "creates a new unassigned user" do
          expect(logger).to receive(:error).with("Lettings log '0ead17cb-1668-442d-898c-0d52879ff592' belongs to legacy user with owner-user-id: 'fake_id' which belongs to a different organisation. Assigning log to 'Unassigned' user.")
          lettings_log_service.send(:create_log, lettings_log_xml)

          lettings_log = LettingsLog.where(old_id: lettings_log_id).first
          expect(lettings_log&.created_by&.name).to eq("Unassigned")
        end

        it "only creates one unassigned user" do
          expect(logger).to receive(:error).with("Lettings log '0ead17cb-1668-442d-898c-0d52879ff592' belongs to legacy user with owner-user-id: 'fake_id' which belongs to a different organisation. Assigning log to 'Unassigned' user.")
          expect(logger).to receive(:error).with("Lettings log 'fake_id' belongs to legacy user with owner-user-id: 'fake_id' which belongs to a different organisation. Assigning log to 'Unassigned' user.")
          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log_xml.at_xpath("//meta:document-id").content = "fake_id"
          lettings_log_service.send(:create_log, lettings_log_xml)

          lettings_log = LettingsLog.where(old_id: lettings_log_id).first
          second_lettings_log = LettingsLog.where(old_id: "fake_id").first
          expect(lettings_log&.created_by).to eq(second_lettings_log&.created_by)
        end

        context "when unassigned user exist for a different organisation" do
          let!(:other_unassigned_user) { create(:user, name: "Unassigned") }

          it "creates a new unassigned user for current organisation" do
            expect(logger).to receive(:error).with("Lettings log '0ead17cb-1668-442d-898c-0d52879ff592' belongs to legacy user with owner-user-id: 'fake_id' which belongs to a different organisation. Assigning log to 'Unassigned' user.")
            lettings_log_service.send(:create_log, lettings_log_xml)

            lettings_log = LettingsLog.where(old_id: lettings_log_id).first
            expect(lettings_log&.created_by&.name).to eq("Unassigned")
            expect(lettings_log&.created_by).not_to eq(other_unassigned_user)
          end
        end
      end

      it "correctly sets imported at date" do
        lettings_log_service.send(:create_log, lettings_log_xml)

        lettings_log = LettingsLog.where(old_id: lettings_log_id).first
        expect(lettings_log&.values_updated_at).to eq(Time.zone.local(2022, 1, 1))
      end

      context "and the void date is after the start date" do
        before { lettings_log_xml.at_xpath("//xmlns:VYEAR").content = 2023 }

        it "does not import the voiddate" do
          lettings_log_service.send(:create_log, lettings_log_xml)

          lettings_log = LettingsLog.where(old_id: lettings_log_id).first
          expect(lettings_log&.voiddate).to be_nil
        end
      end

      context "and the organisation legacy ID does not exist" do
        before { lettings_log_xml.at_xpath("//xmlns:OWNINGORGID").content = 99_999 }

        it "raises an exception" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .to raise_error(RuntimeError, "Organisation not found with legacy ID 99999")
        end
      end

      context "and a person is under 16" do
        before { lettings_log_xml.at_xpath("//xmlns:P2Age").content = 14 }

        context "when the economic status is set to refuse" do
          before { lettings_log_xml.at_xpath("//xmlns:P2Eco").content = "10) Refused" }

          it "sets the economic status to child under 16" do
            # The update is done when calculating derived variables
            lettings_log_service.send(:create_log, lettings_log_xml)

            lettings_log = LettingsLog.where(old_id: lettings_log_id).first
            expect(lettings_log&.ecstat2).to be(9)
          end
        end

        context "when the relationship to lead tenant is set to refuse" do
          before { lettings_log_xml.at_xpath("//xmlns:P2Rel").content = "Refused" }

          it "sets the relationship to lead tenant to child" do
            lettings_log_service.send(:create_log, lettings_log_xml)

            lettings_log = LettingsLog.where(old_id: lettings_log_id).first
            expect(lettings_log&.relat2).to eq("C")
          end
        end
      end

      context "and this is an internal transfer that is in-progress with invalid answers" do
        before do
          lettings_log_xml.at_xpath("//meta:status").content = "submitted-invalid"
          lettings_log_xml.at_xpath("//xmlns:P2Age").content = 999
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the invalid answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.age2).to be_nil
          expect(lettings_log.ecstat2).to be_nil
        end
      end

      context "and it has zero earnings" do
        before do
          lettings_log_xml.at_xpath("//meta:status").content = "submitted"
          lettings_log_xml.at_xpath("//xmlns:Q8Money").content = 0
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the invalid answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.earnings).to be_nil
          expect(lettings_log.incref).to eq(1)
          expect(lettings_log.net_income_known).to eq(2)
        end
      end

      context "and an invalid tenancy length for tenancy type" do
        before do
          lettings_log_xml.at_xpath("//meta:status").content = "submitted"
          lettings_log_xml.at_xpath("//xmlns:_2cYears").content = "1"
          lettings_log_xml.at_xpath("//xmlns:Q2b").content = "4"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the invalid answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.tenancylength).to be_nil
          expect(lettings_log.tenancy).to be_nil
        end
      end

      context "and an lead tenant must be under 26 if childrens home or foster care" do
        before do
          lettings_log_xml.at_xpath("//meta:status").content = "submitted"
          lettings_log_xml.at_xpath("//xmlns:Q11").content = "13"
          lettings_log_xml.at_xpath("//xmlns:P1Age").content = "26"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the invalid answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.age1).to be_nil
          expect(lettings_log.prevten).to be_nil
        end
      end

      context "and is a carehome but missing carehome charge" do
        let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

        before do
          lettings_log_xml.at_xpath("//meta:status").content = "submitted"
          lettings_log_xml.at_xpath("//xmlns:_1cmangroupcode").content = scheme2.old_visible_id
          scheme2.update!(registered_under_care_act: 2)
          lettings_log_xml.at_xpath("//xmlns:Q18b").content = ""
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the invalid answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.is_carehome).to be_truthy
          expect(lettings_log.chcharge).to be_nil
        end
      end

      context "and is a other tenancy but missing tenancyother" do
        let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

        before do
          lettings_log_xml.at_xpath("//meta:status").content = "saved"
          lettings_log_xml.at_xpath("//xmlns:Q2b").content = "3"
          lettings_log_xml.at_xpath("//xmlns:Q2ba").content = ""
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the invalid answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.tenancy).to be_nil
          expect(lettings_log.tenancyother).to be_nil
        end
      end

      context "and submitted log has errors" do
        let(:lettings_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }

        before do
          lettings_log_xml.at_xpath("//meta:status").content = "submitted"
          lettings_log_xml.at_xpath("//xmlns:HHMEMB").content = "32"
        end

        it "logs the error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
          .to raise_error(ActiveRecord::RecordInvalid)

          expect(logs_string.string).to include("Failed to import")
          expect(logs_string.string).to include("ERROR -- : Validation error: Field hhmemb")
          expect(logs_string.string).to include("Error message: outside_the_range")
        end
      end

      context "and this is an internal transfer from a non social housing" do
        before do
          lettings_log_xml.at_xpath("//xmlns:Q11").content = "9 Residential care home"
          lettings_log_xml.at_xpath("//xmlns:Q16").content = "1 Internal Transfer"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the referral answer" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
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
            expect { lettings_log_service.send(:create_log, lettings_log_xml) }
              .not_to raise_error
          end

          it "clears out the referral answer" do
            allow(logger).to receive(:warn)

            lettings_log_service.send(:create_log, lettings_log_xml)
            lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

            expect(lettings_log).not_to be_nil
            expect(lettings_log.referral).to be_nil
          end
        end
      end

      context "and this is a non temporary acommodation" do
        before do
          lettings_log_xml.at_xpath("//xmlns:Q27").content = "9"
          lettings_log_xml.at_xpath("//xmlns:Q11").content = "4"
          lettings_log_xml.at_xpath("//xmlns:VDAY").content = ""
          lettings_log_xml.at_xpath("//xmlns:VMONTH").content = ""
          lettings_log_xml.at_xpath("//xmlns:VYEAR").content = ""
          lettings_log_xml.at_xpath("//xmlns:MRCDAY").content = ""
          lettings_log_xml.at_xpath("//xmlns:MRCMONTH").content = ""
          lettings_log_xml.at_xpath("//xmlns:MRCYEAR").content = ""
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the vacancy reason answer" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.rsnvac).to be_nil
          expect(lettings_log.prevten).to be_nil
        end
      end

      context "and the number of times the property was relet is over 150" do
        before do
          lettings_log_xml.at_xpath("//xmlns:Q20").content = "155"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the number offered answer" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.offered).to be_nil
        end
      end

      context "and the number of times the property was relet is 0.00" do
        before do
          lettings_log_xml.at_xpath("//xmlns:Q20").content = "0.00"
        end

        it "does not raise an error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "does not clear offered answer" do
          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.offered).to equal(0)
        end
      end

      context "and the number of times the property was relet is 0.01" do
        before do
          lettings_log_xml.at_xpath("//xmlns:Q20").content = "0.01"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the number offered answer" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.offered).to be_nil
        end
      end

      context "and the gender identity is refused" do
        before do
          lettings_log_xml.at_xpath("//xmlns:P1Sex").content = "Person prefers not to say"
        end

        it "does not raise an error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "saves the correct answer" do
          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.sex1).to eq("R")
        end
      end

      context "and the relationship is refused" do
        before do
          lettings_log_xml.at_xpath("//xmlns:P2Rel").content = "Person prefers not to say"
        end

        it "does not raise an error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "saves the correct answer" do
          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.relat2).to eq("R")
        end
      end

      context "when the log being imported was manually entered" do
        it "sets the creation method correctly" do
          lettings_log_service.send(:create_log, lettings_log_xml)

          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)
          expect(lettings_log.creation_method_single_log?).to be true
        end
      end

      context "when the log being imported was bulk uploaded" do
        before do
          metadata = lettings_log_xml.at_xpath("//meta:metadata", { "meta" => "http://data.gov.uk/core/metadata" })
          metadata << "<meta:upload-id>#{SecureRandom.uuid}</meta:upload-id>"
        end

        it "sets the creation method correctly" do
          lettings_log_service.send(:create_log, lettings_log_xml)

          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)
          expect(lettings_log.creation_method_bulk_upload?).to be true
        end
      end

      context "and income over the max" do
        before do
          lettings_log_xml.at_xpath("//xmlns:Q8Money").content = "25000"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the working situation answer" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.ecstat1).to be_nil
          expect(lettings_log.earnings).to eq(25_000)
        end
      end

      context "and age over the max" do
        before do
          lettings_log_xml.at_xpath("//xmlns:P2Age").content = "121"
          lettings_log_xml.at_xpath("//xmlns:P2Eco").content = "7"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the age answer" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.age2).to be_nil
          expect(lettings_log.age2_known).to be_nil
        end
      end

      context "and age 3 over the max" do
        before do
          lettings_log_xml.at_xpath("//xmlns:P3Age").content = "121"
          lettings_log_xml.at_xpath("//xmlns:P3Eco").content = "7"
          lettings_log_xml.at_xpath("//xmlns:HHMEMB").content = "3"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the age answer" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.age3).to be_nil
          expect(lettings_log.age3_known).to be_nil
        end
      end

      context "and beds over the max" do
        before do
          lettings_log_xml.at_xpath("//xmlns:Q22").content = "13"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the bedrooms answer" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.beds).to be_nil
        end
      end

      context "and beds over the max for the number of tenants" do
        before do
          lettings_log_xml.at_xpath("//xmlns:Q22").content = "4"
          lettings_log_xml.at_xpath("//xmlns:HHMEMB").content = "1"
          lettings_log_xml.at_xpath("//xmlns:Q23").content = "4"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the bedrooms answer" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.beds).to be_nil
        end
      end

      context "and carehome charges and other charges are entered" do
        let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

        before do
          lettings_log_xml.at_xpath("//xmlns:Q18b").content = "20"
          lettings_log_xml.at_xpath("//xmlns:Q18c").content = ""
          lettings_log_xml.at_xpath("//xmlns:Q18ai").content = ""
          lettings_log_xml.at_xpath("//xmlns:Q18aii").content = "0"
          lettings_log_xml.at_xpath("//xmlns:Q18aiii").content = ""
          lettings_log_xml.at_xpath("//xmlns:Q18aiv").content = ""
          lettings_log_xml.at_xpath("//xmlns:Q18av").content = ""
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the charges answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.tcharge).to be_nil
        end
      end

      context "and scharge is under 0" do
        let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

        before do
          lettings_log_xml.at_xpath("//xmlns:Q18aii").content = "-1"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the charges answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.brent).to be_nil
          expect(lettings_log.scharge).to be_nil
          expect(lettings_log.pscharge).to be_nil
          expect(lettings_log.supcharg).to be_nil
          expect(lettings_log.tcharge).to be_nil
        end
      end

      context "and tshortfall is not positive" do
        let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

        before do
          lettings_log_xml.at_xpath("//xmlns:Q18d").content = "1"
          lettings_log_xml.at_xpath("//xmlns:Q6Ben").content = "1"
          lettings_log_xml.at_xpath("//xmlns:Q18dyes").content = "0"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the tshortfall answer" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.tshortfall).to be_nil
          expect(lettings_log.tshortfall_known).to be_nil
        end
      end

      context "and it has temporary referral in non temporary accommodation" do
        before do
          lettings_log_xml.at_xpath("//xmlns:Q27").content = "9"
          lettings_log_xml.at_xpath("//xmlns:Q16").content = "8"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the referral answer" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.referral).to be_nil
        end
      end

      context "and pscharge is out of range" do
        before do
          lettings_log_xml.at_xpath("//xmlns:Q17").content = "1"
          lettings_log_xml.at_xpath("//xmlns:Q18aiii").content = "36"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the charges answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.pscharge).to be_nil
          expect(lettings_log.tcharge).to be_nil
        end
      end

      context "and supcharg is out of range" do
        before do
          lettings_log_xml.at_xpath("//xmlns:Q17").content = "1"
          lettings_log_xml.at_xpath("//xmlns:Q18aiv").content = "46"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the charges answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.supcharg).to be_nil
          expect(lettings_log.tcharge).to be_nil
        end
      end

      context "and scharge is out of range" do
        before do
          lettings_log_xml.at_xpath("//xmlns:Q17").content = "1"
          lettings_log_xml.at_xpath("//xmlns:Q18aii").content = "156"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the charges answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.scharge).to be_nil
          expect(lettings_log.tcharge).to be_nil
        end
      end

      context "and tcharge is less than £10 per week" do
        before do
          lettings_log_xml.at_xpath("//xmlns:Q18ai").content = "1"
          lettings_log_xml.at_xpath("//xmlns:Q18aii").content = "2"
          lettings_log_xml.at_xpath("//xmlns:Q18aiii").content = "3"
          lettings_log_xml.at_xpath("//xmlns:Q18aiv").content = "3"
          lettings_log_xml.at_xpath("//xmlns:Q18av").content = "9"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the charges answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.tcharge).to be_nil
        end
      end

      context "and rent is higher than the absolute maximum expected for a property " do
        before do
          LaRentRange.create!(
            ranges_rent_id: "2",
            la: "E08000035",
            beds: 2,
            lettype: 1,
            soft_min: 12.41,
            soft_max: 89.54,
            hard_min: 9.87,
            hard_max: 100.99,
            start_year: 2021,
          )

          lettings_log_xml.at_xpath("//xmlns:Q18ai").content = "500"
          lettings_log_xml.at_xpath("//xmlns:Q18aii").content = "2"
          lettings_log_xml.at_xpath("//xmlns:Q18aiii").content = "3"
          lettings_log_xml.at_xpath("//xmlns:Q18aiv").content = "3"
          lettings_log_xml.at_xpath("//xmlns:Q18av").content = "508"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the charges answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.tcharge).to be_nil
        end
      end

      context "and rent is lower than the absolute minimum expected for a property " do
        before do
          LaRentRange.create!(
            ranges_rent_id: "2",
            la: "E08000035",
            beds: 2,
            lettype: 1,
            soft_min: 12.41,
            soft_max: 89.54,
            hard_min: 12.87,
            hard_max: 100.99,
            start_year: 2021,
          )

          lettings_log_xml.at_xpath("//xmlns:Q18ai").content = "8"
          lettings_log_xml.at_xpath("//xmlns:Q18aii").content = "1"
          lettings_log_xml.at_xpath("//xmlns:Q18aiii").content = "1"
          lettings_log_xml.at_xpath("//xmlns:Q18aiv").content = "1"
          lettings_log_xml.at_xpath("//xmlns:Q18av").content = "11"
          lettings_log_xml.at_xpath("//xmlns:Q17").content = "1"
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the charges answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.tcharge).to be_nil
        end
      end

      context "and location is not active during the period" do
        let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

        before do
          location = Location.find_by(old_visible_id: "10")
          FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2021, 10, 10), location:)
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the location answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.location).to be_nil
          expect(lettings_log.scheme).to be_nil
        end
      end

      context "and no scheme locations are confirmed" do
        let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

        before do
          scheme = Scheme.find_by(old_visible_id: "0123")
          scheme.locations.update!(confirmed: false, mobility_type: nil)
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the location answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.location).to be_nil
          expect(lettings_log.scheme).to be_nil
        end
      end

      context "and unconfirmed/incomplete location is selected" do
        let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

        before do
          scheme = Scheme.find_by(old_visible_id: "0123")
          scheme.locations.update!(confirmed: false, mobility_type: nil)
          scheme.locations << create(:location)
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the location answers" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.location).to be_nil
          expect(lettings_log.scheme).to be_nil
        end
      end

      context "and carehome charges are out of range" do
        let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

        before do
          scheme1.update!(registered_under_care_act: 2)
          lettings_log_xml.at_xpath("//xmlns:Q18b").content = "6000"
          lettings_log_xml.at_xpath("//xmlns:Q17").content = "1"
          lettings_log_xml.at_xpath("//xmlns:Q18ai").content = ""
          lettings_log_xml.at_xpath("//xmlns:Q18aii").content = ""
          lettings_log_xml.at_xpath("//xmlns:Q18aiii").content = ""
          lettings_log_xml.at_xpath("//xmlns:Q18aiv").content = ""
          lettings_log_xml.at_xpath("//xmlns:Q18av").content = ""
        end

        it "intercepts the relevant validation error" do
          expect { lettings_log_service.send(:create_log, lettings_log_xml) }
            .not_to raise_error
        end

        it "clears out the chcharge answer" do
          allow(logger).to receive(:warn)

          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log).not_to be_nil
          expect(lettings_log.chcharge).to be_nil
        end
      end

      context "and the net income soft validation is triggered (net_income_value_check)" do
        before do
          lettings_log_xml.at_xpath("//xmlns:Q8a").content = "1 Weekly"
          lettings_log_xml.at_xpath("//xmlns:Q8Money").content = 890.00
        end

        it "completes the log" do
          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)
          expect(lettings_log.status).to eq("completed")
        end
      end

      context "and the rent soft validation is triggered (rent_value_check)" do
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
          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)
          expect(lettings_log.status).to eq("completed")
        end
      end

      context "and the retirement soft validation is triggered (retirement_value_check)" do
        before do
          lettings_log_xml.at_xpath("//xmlns:P1Age").content = 68
          lettings_log_xml.at_xpath("//xmlns:P1Eco").content = "6) Not Seeking Work"
        end

        it "completes the log" do
          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)
          expect(lettings_log.status).to eq("completed")
        end
      end

      context "and the carehome charge soft validation is triggered (carehome_charge_value_check)" do
        let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

        before do
          scheme2.update!(registered_under_care_act: 2)
          lettings_log_xml.at_xpath("//xmlns:_1cmangroupcode").content = scheme2.old_visible_id
          lettings_log_xml.at_xpath("//xmlns:Q18b").content = ""
          lettings_log_xml.at_xpath("//xmlns:Q18ai").content = ""
          lettings_log_xml.at_xpath("//xmlns:Q18aii").content = ""
          lettings_log_xml.at_xpath("//xmlns:Q18aiii").content = ""
          lettings_log_xml.at_xpath("//xmlns:Q18aiv").content = ""
          lettings_log_xml.at_xpath("//xmlns:Q18av").content = ""
        end

        it "completes the log" do
          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)
          expect(lettings_log.status).to eq("completed")
        end
      end

      context "and this is a supported housing log with multiple locations under a scheme" do
        let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

        it "sets the scheme and location values" do
          expect(logger).not_to receive(:warn)
          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log.scheme_id).not_to be_nil
          expect(lettings_log.location_id).not_to be_nil
          expect(lettings_log.status).to eq("completed")
        end
      end

      context "and the scheme and location is not given" do
        let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

        before do
          lettings_log_xml.at_xpath("//xmlns:_1cmangroupcode").content = ""
          lettings_log_xml.at_xpath("//xmlns:_1cschemecode").content = ""
          lettings_log_xml.at_xpath("//xmlns:Q25").content = ""
          lettings_log_xml.at_xpath("//meta:status").content = "saved"
        end

        it "saves log without location and scheme" do
          expect(logger).not_to receive(:warn)
          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log.scheme_id).to be_nil
          expect(lettings_log.location_id).to be_nil
          expect(lettings_log.status).to eq("in_progress")
        end
      end

      context "and the scheme and location are not valid" do
        let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

        before do
          lettings_log_xml.at_xpath("//xmlns:_1cmangroupcode").content = "999"
          lettings_log_xml.at_xpath("//xmlns:_1cschemecode").content = "999"
        end

        it "saves log without location and scheme" do
          expect(logger).not_to receive(:warn)
          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log.scheme_id).to be_nil
          expect(lettings_log.location_id).to be_nil
          expect(lettings_log.status).to eq("in_progress")
        end
      end

      context "and this is a supported housing log with a single location under a scheme" do
        let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

        before { lettings_log_xml.at_xpath("//xmlns:_1cmangroupcode").content = scheme2.old_visible_id }

        it "sets the scheme and location values" do
          expect(logger).not_to receive(:warn)
          lettings_log_service.send(:create_log, lettings_log_xml)
          lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

          expect(lettings_log.scheme_id).not_to be_nil
          expect(lettings_log.location_id).not_to be_nil
          expect(lettings_log.status).to eq("completed")
        end
      end
    end
  end

  context "with 22/23 logs" do
    subject(:lettings_log_service) { described_class.new(storage_service, logger) }

    around do |example|
      Timecop.freeze(Time.zone.local(2023, 1, 1)) do
        Singleton.__init__(FormHandler)
        example.run
      end
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    let(:storage_service) { instance_double(Storage::S3Service) }
    let(:logs_string) { StringIO.new }
    let(:file_logger) { Logger.new(logs_string) }
    let(:logger) { MultiLogger.new(file_logger) }

    let(:real_2021_2022_form) { Form.new("config/forms/2021_2022.json") }
    let(:real_2022_2023_form) { Form.new("config/forms/2022_2023.json") }
    let(:fixture_directory) { "spec/fixtures/imports/logs" }

    let(:organisation) { FactoryBot.create(:organisation, old_visible_id: "1", provider_type: "PRP") }
    let(:managing_organisation) { FactoryBot.create(:organisation, old_visible_id: "2", provider_type: "PRP") }
    let(:scheme1) { FactoryBot.create(:scheme, old_visible_id: "0123", owning_organisation: organisation) }
    let(:scheme2) { FactoryBot.create(:scheme, old_visible_id: "456", owning_organisation: organisation) }

    def open_file(directory, filename)
      File.open("#{directory}/#{filename}.xml")
    end

    before do
      WebMock.stub_request(:get, /api.postcodes.io\/postcodes\/LS166FT/)
             .to_return(status: 200, body: '{"status":200,"result":{"admin_district":"Westminster","codes":{"admin_district":"E08000035"}}}', headers: {})

      allow(Organisation).to receive(:find_by).and_return(nil)
      allow(Organisation).to receive(:find_by).with(old_visible_id: organisation.old_visible_id).and_return(organisation)
      allow(Organisation).to receive(:find_by).with(old_visible_id: managing_organisation.old_visible_id).and_return(managing_organisation)

      # Created by users
      FactoryBot.create(:user, old_user_id: "c3061a2e6ea0b702e6f6210d5c52d2a92612d2aa", organisation:)
      FactoryBot.create(:user, old_user_id: "e29c492473446dca4d50224f2bb7cf965a261d6f", organisation:)

      # Location setup
      FactoryBot.create(:location, old_visible_id: "10", postcode: "LS166FT", scheme_id: scheme1.id, mobility_type: "W", startdate: Time.zone.local(2021, 4, 1))
      FactoryBot.create(:location, scheme_id: scheme1.id, startdate: Time.zone.local(2021, 4, 1))
      FactoryBot.create(:location, old_visible_id: "10", postcode: "LS166FT", scheme_id: scheme2.id, mobility_type: "W", startdate: Time.zone.local(2021, 4, 1))

      # Stub the form handler to use the real form
      allow(FormHandler.instance).to receive(:get_form).with("current_lettings").and_return(real_2022_2023_form)
      allow(FormHandler.instance).to receive(:get_form).with("previous_lettings").and_return(real_2021_2022_form)
      allow(FormHandler.instance).to receive(:get_form).with("next_lettings").and_return(real_2022_2023_form)
    end

    context "when importing lettings logs" do
      let(:remote_folder) { "lettings_logs" }
      let(:lettings_log_id) { "00d2343e-d5fa-4c89-8400-ec3854b0f2b4" }
      let(:sales_log) { "shared_ownership_sales_log" }

      before do
        # Stub the S3 file listing and download
        allow(storage_service).to receive(:list_files)
                                    .and_return(%W[#{remote_folder}/#{lettings_log_id}.xml #{remote_folder}/#{sales_log}.xml])
        allow(storage_service).to receive(:get_file_io)
                                    .with("#{remote_folder}/#{lettings_log_id}.xml")
                                    .and_return(open_file(fixture_directory, lettings_log_id), open_file(fixture_directory, lettings_log_id))
        allow(storage_service).to receive(:get_file_io)
                                    .with("#{remote_folder}/#{sales_log}.xml")
                                    .and_return(open_file(fixture_directory, sales_log), open_file(fixture_directory, sales_log))
      end

      it "successfully create all lettings logs" do
        expect(logger).not_to receive(:error)
        expect(logger).not_to receive(:warn)
        expect(logger).not_to receive(:info)
        expect { lettings_log_service.create_logs(remote_folder) }
          .to change(LettingsLog, :count).by(1)
      end

      it "does not by default update existing lettings logs" do
        expect(logger).not_to receive(:error)
        expect(logger).not_to receive(:warn)
        expect(logger).not_to receive(:info).with(/Updating lettings log/)

        start_time = Time.current

        expect { 2.times { lettings_log_service.create_logs(remote_folder) } }
        .to change(LettingsLog, :count).by(1)

        end_time = Time.current

        updated_logs = LettingsLog.where(updated_at: start_time..end_time).count
        expect(updated_logs).to eq(0)
      end

      context "with updates allowed" do
        subject(:lettings_log_service) { described_class.new(storage_service, logger, allow_updates: true) }

        it "only updates existing lettings logs" do
          expect(logger).not_to receive(:error)
          expect(logger).not_to receive(:warn)

          start_time = Time.current

          expect { 2.times { lettings_log_service.create_logs(remote_folder) } }
            .to change(LettingsLog, :count).by(1)

          end_time = Time.current

          updated_logs = LettingsLog.where(updated_at: start_time..end_time).count
          expect(updated_logs).to eq(1)
        end
      end

      it "creates organisation relationship once" do
        expect(logger).not_to receive(:error)
        expect(logger).not_to receive(:warn)
        expect { lettings_log_service.create_logs(remote_folder) }
          .to change(OrganisationRelationship, :count).by(1)
      end
    end

    context "when this is a joint tenancy with 1 person in the household" do
      let(:lettings_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }
      let(:lettings_log_file) { open_file(fixture_directory, lettings_log_id) }
      let(:lettings_log_xml) { Nokogiri::XML(lettings_log_file) }

      before do
        lettings_log_xml.at_xpath("//xmlns:joint").content = "1"
        lettings_log_xml.at_xpath("//xmlns:HHMEMB").content = "1"
        lettings_log_xml.at_xpath("//xmlns:P2Age").content = ""
        lettings_log_xml.at_xpath("//xmlns:P2Rel").content = ""
        lettings_log_xml.at_xpath("//xmlns:P2Sex").content = ""
        lettings_log_xml.at_xpath("//xmlns:P1Nat").content = "18"
        lettings_log_xml.at_xpath("//xmlns:P2Eco").content = ""
        lettings_log_xml.at_xpath("//xmlns:DAY").content = "2"
        lettings_log_xml.at_xpath("//xmlns:MONTH").content = "10"
        lettings_log_xml.at_xpath("//xmlns:YEAR").content = "2022"
      end

      it "intercepts the relevant validation error" do
        expect { lettings_log_service.send(:create_log, lettings_log_xml) }
          .not_to raise_error
      end

      it "clears out the referral answer" do
        allow(logger).to receive(:warn)

        lettings_log_service.send(:create_log, lettings_log_xml)
        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

        expect(lettings_log).not_to be_nil
        expect(lettings_log.joint).to be_nil
        expect(lettings_log.hhmemb).to eq(1)
      end
    end

    context "when there are no outstanding charges but outstanding amount is given" do
      let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }
      let(:lettings_log_file) { open_file(fixture_directory, lettings_log_id) }
      let(:lettings_log_xml) { Nokogiri::XML(lettings_log_file) }

      before do
        FormHandler.instance.use_fake_forms!
        Singleton.__init__(FormHandler)

        lettings_log_xml.at_xpath("//xmlns:DAY").content = "10"
        lettings_log_xml.at_xpath("//xmlns:MONTH").content = "10"
        lettings_log_xml.at_xpath("//xmlns:YEAR").content = "2022"
        lettings_log_xml.at_xpath("//xmlns:P1Nat").content = "18"
        lettings_log_xml.at_xpath("//xmlns:Q18d").content = "2"
        lettings_log_xml.at_xpath("//xmlns:Q18dyes").content = "20"
        lettings_log_xml.at_xpath("//xmlns:_2cYears").content = ""
        lettings_log_xml.at_xpath("//xmlns:Inj").content = ""
        lettings_log_xml.at_xpath("//xmlns:LeftAF").content = ""
      end

      after do
        FormHandler.instance.use_real_forms!
        Singleton.__init__(FormHandler)
      end

      it "intercepts the relevant validation error" do
        expect { lettings_log_service.send(:create_log, lettings_log_xml) }
          .not_to raise_error
      end

      it "clears out the referral answer" do
        allow(logger).to receive(:warn)
        lettings_log_service.send(:create_log, lettings_log_xml)
        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

        expect(lettings_log).not_to be_nil
        expect(lettings_log.tshortfall).to be_nil
        expect(lettings_log.hbrentshortfall).to be_nil
      end
    end

    context "and an error is added to tcharge for in progress log" do
      let(:lettings_log_id) { "00d2343e-d5fa-4c89-8400-ec3854b0f2b4" }
      let(:lettings_log_file) { open_file(fixture_directory, lettings_log_id) }
      let(:lettings_log_xml) { Nokogiri::XML(lettings_log_file) }

      before do
        lettings_log_xml.at_xpath("//meta:status").content = "saved"
        lettings_log_xml.at_xpath("//xmlns:Q18ai").content = "1"
        lettings_log_xml.at_xpath("//xmlns:Q18aii").content = "2"
        lettings_log_xml.at_xpath("//xmlns:Q18aiii").content = "3"
        lettings_log_xml.at_xpath("//xmlns:Q18aiv").content = "3"
        lettings_log_xml.at_xpath("//xmlns:Q18av").content = "9"
      end

      it "intercepts the relevant validation error" do
        lettings_log_service.send(:create_log, lettings_log_xml)
      end

      it "clears out the invalid answers" do
        allow(logger).to receive(:warn)

        lettings_log_service.send(:create_log, lettings_log_xml)
        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

        expect(lettings_log).not_to be_nil
        expect(lettings_log.tcharge).to be_nil
        expect(lettings_log.brent).to be_nil
        expect(lettings_log.scharge).to be_nil
        expect(lettings_log.pscharge).to be_nil
        expect(lettings_log.supcharg).to be_nil
      end
    end

    context "when the organisation does not charge rent in certain period" do
      let(:lettings_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }
      let(:lettings_log_file) { open_file(fixture_directory, lettings_log_id) }
      let(:lettings_log_xml) { Nokogiri::XML(lettings_log_file) }

      before do
        FormHandler.instance.use_fake_forms!
        create(:organisation_rent_period, organisation: managing_organisation, rent_period: 2)

        lettings_log_xml.at_xpath("//xmlns:DAY").content = "10"
        lettings_log_xml.at_xpath("//xmlns:MONTH").content = "10"
        lettings_log_xml.at_xpath("//xmlns:YEAR").content = "2022"
        lettings_log_xml.at_xpath("//xmlns:Q17").content = "1"
        lettings_log_xml.at_xpath("//xmlns:Q18c").content = ""
        lettings_log_xml.at_xpath("//xmlns:Q18ai").content = ""
        lettings_log_xml.at_xpath("//xmlns:Q18aiii").content = ""
        lettings_log_xml.at_xpath("//xmlns:Q18aiv").content = ""
        lettings_log_xml.at_xpath("//xmlns:Q18av").content = ""
        lettings_log_xml.at_xpath("//xmlns:Q2b").content = ""
        lettings_log_xml.at_xpath("//xmlns:_2cYears").content = ""
        lettings_log_xml.at_xpath("//xmlns:P1Nat").content = ""
        lettings_log_xml.at_xpath("//xmlns:_1cschemecode").content = ""
        lettings_log_xml.at_xpath("//xmlns:_1cmangroupcode").content = ""
        lettings_log_xml.at_xpath("//xmlns:Q25").content = ""
      end

      after do
        FormHandler.instance.use_real_forms!
        Singleton.__init__(FormHandler)
      end

      it "intercepts the relevant validation error" do
        expect { lettings_log_service.send(:create_log, lettings_log_xml) }
        .not_to raise_error
      end

      it "clears out the referral answer" do
        allow(logger).to receive(:warn)
        lettings_log_service.send(:create_log, lettings_log_xml)
        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

        expect(lettings_log).not_to be_nil
        expect(lettings_log.period).to be_nil
      end
    end

    context "when this is a renewal and layear is just moved to local authority" do
      let(:lettings_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }
      let(:lettings_log_file) { open_file(fixture_directory, lettings_log_id) }
      let(:lettings_log_xml) { Nokogiri::XML(lettings_log_file) }

      before do
        lettings_log_xml.at_xpath("//xmlns:DAY").content = "10"
        lettings_log_xml.at_xpath("//xmlns:MONTH").content = "10"
        lettings_log_xml.at_xpath("//xmlns:YEAR").content = "2022"
        lettings_log_xml.at_xpath("//xmlns:Q27").content = "14"
        lettings_log_xml.at_xpath("//xmlns:Q12c").content = "1"
        lettings_log_xml.at_xpath("//xmlns:Q26").content = "1"
        lettings_log_xml.at_xpath("//xmlns:MRCDAY").content = ""
        lettings_log_xml.at_xpath("//xmlns:MRCMONTH").content = ""
        lettings_log_xml.at_xpath("//xmlns:MRCYEAR").content = ""
        lettings_log_xml.at_xpath("//xmlns:VDAY").content = "10"
        lettings_log_xml.at_xpath("//xmlns:VMONTH").content = "10"
        lettings_log_xml.at_xpath("//xmlns:VYEAR").content = "2022"
        lettings_log_xml.at_xpath("//xmlns:P1Nat").content = ""
        lettings_log_xml.at_xpath("//xmlns:Q9a").content = ""
        lettings_log_xml.at_xpath("//xmlns:Q11").content = "32"
        lettings_log_xml.at_xpath("//xmlns:Q16").content = "1"
        lettings_log_xml.at_xpath("//xmlns:Q20").content = "0"
      end

      it "intercepts the relevant validation error" do
        expect { lettings_log_service.send(:create_log, lettings_log_xml) }
          .not_to raise_error
      end

      it "clears out the layear answer" do
        allow(logger).to receive(:warn)

        lettings_log_service.send(:create_log, lettings_log_xml)
        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

        expect(lettings_log).not_to be_nil
        expect(lettings_log.layear).to be_nil
      end
    end

    context "when this is a void date is after major repairs day" do
      let(:lettings_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }
      let(:lettings_log_file) { open_file(fixture_directory, lettings_log_id) }
      let(:lettings_log_xml) { Nokogiri::XML(lettings_log_file) }

      before do
        lettings_log_xml.at_xpath("//xmlns:DAY").content = "10"
        lettings_log_xml.at_xpath("//xmlns:MONTH").content = "10"
        lettings_log_xml.at_xpath("//xmlns:YEAR").content = "2022"
        lettings_log_xml.at_xpath("//xmlns:MRCDAY").content = "9"
        lettings_log_xml.at_xpath("//xmlns:MRCMONTH").content = "9"
        lettings_log_xml.at_xpath("//xmlns:MRCYEAR").content = "2021"
        lettings_log_xml.at_xpath("//xmlns:VDAY").content = "10"
        lettings_log_xml.at_xpath("//xmlns:VMONTH").content = "10"
        lettings_log_xml.at_xpath("//xmlns:VYEAR").content = "2021"
        lettings_log_xml.at_xpath("//xmlns:P1Nat").content = ""
      end

      it "intercepts the relevant validation error" do
        expect { lettings_log_service.send(:create_log, lettings_log_xml) }
          .not_to raise_error
      end

      it "clears out the voiddate and mrcdate answers" do
        allow(logger).to receive(:warn)

        lettings_log_service.send(:create_log, lettings_log_xml)
        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

        expect(lettings_log).not_to be_nil
        expect(lettings_log.voiddate).to be_nil
        expect(lettings_log.mrcdate).to be_nil
      end
    end

    context "when shortfall is more than basic rent" do
      let(:lettings_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }
      let(:lettings_log_file) { open_file(fixture_directory, lettings_log_id) }
      let(:lettings_log_xml) { Nokogiri::XML(lettings_log_file) }

      before do
        lettings_log_xml.at_xpath("//xmlns:DAY").content = "10"
        lettings_log_xml.at_xpath("//xmlns:MONTH").content = "10"
        lettings_log_xml.at_xpath("//xmlns:YEAR").content = "2022"
        lettings_log_xml.at_xpath("//xmlns:P1Nat").content = ""
        lettings_log_xml.at_xpath("//xmlns:Q18dyes").content = "200"
        lettings_log_xml.at_xpath("//xmlns:Q18ai").content = "20"
        lettings_log_xml.at_xpath("//xmlns:Q18aii").content = "20"
        lettings_log_xml.at_xpath("//xmlns:Q18aiii").content = "40"
        lettings_log_xml.at_xpath("//xmlns:Q18aiv").content = "20"
        lettings_log_xml.at_xpath("//xmlns:Q18av").content = "100"
      end

      it "intercepts the relevant validation error" do
        expect { lettings_log_service.send(:create_log, lettings_log_xml) }
          .not_to raise_error
      end

      it "clears out the voiddate and mrcdate answers" do
        allow(logger).to receive(:warn)

        lettings_log_service.send(:create_log, lettings_log_xml)
        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

        expect(lettings_log).not_to be_nil
        expect(lettings_log.tshortfall).to be_nil
        expect(lettings_log.tshortfall_known).to be_nil
      end
    end

    context "and the earnings is not a whole number" do
      let(:lettings_log_id) { "00d2343e-d5fa-4c89-8400-ec3854b0f2b4" }
      let(:lettings_log_file) { open_file(fixture_directory, lettings_log_id) }
      let(:lettings_log_xml) { Nokogiri::XML(lettings_log_file) }

      before do
        lettings_log_xml.at_xpath("//meta:status").content = "submitted"
        lettings_log_xml.at_xpath("//xmlns:Q8a").content = "1 Weekly"
        lettings_log_xml.at_xpath("//xmlns:Q8Money").content = 100.59
        lettings_log_xml.at_xpath("//xmlns:Q8Refused").content = ""
      end

      it "does not error" do
        expect { lettings_log_service.send(:create_log, lettings_log_xml) }
          .not_to raise_error
      end

      it "rounds the earnings value" do
        allow(logger).to receive(:warn)

        lettings_log_service.send(:create_log, lettings_log_xml)
        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)

        expect(lettings_log).not_to be_nil
        expect(lettings_log.earnings).to eq(101)
      end
    end

    context "when setting location fields for 23/24 logs" do
      let(:lettings_log_id) { "00d2343e-d5fa-4c89-8400-ec3854b0f2b4" }
      let(:lettings_log_file) { open_file(fixture_directory, lettings_log_id) }
      let(:lettings_log_xml) { Nokogiri::XML(lettings_log_file) }

      around do |example|
        Timecop.freeze(Time.zone.local(2023, 4, 1)) do
          Singleton.__init__(FormHandler)
          example.run
        end
        Timecop.return
        Singleton.__init__(FormHandler)
      end

      before do
        lettings_log_xml.at_xpath("//xmlns:DAY").content = "10"
        lettings_log_xml.at_xpath("//xmlns:MONTH").content = "4"
        lettings_log_xml.at_xpath("//xmlns:YEAR").content = "2023"
        lettings_log_xml.at_xpath("//xmlns:UPRN").content = "123456781234"
        lettings_log_xml.at_xpath("//xmlns:AddressLine1").content = "address 1"
        lettings_log_xml.at_xpath("//xmlns:AddressLine2").content = "address 2"
        lettings_log_xml.at_xpath("//xmlns:TownCity").content = "towncity"
        lettings_log_xml.at_xpath("//xmlns:County").content = "county"
        lettings_log_xml.at_xpath("//xmlns:POSTCODE").content = "A1"
        lettings_log_xml.at_xpath("//xmlns:POSTCOD2").content = "1AA"

        body = {
          results: [
            {
              DPA: {
                "POSTCODE": "LS16 6FT",
                "POST_TOWN": "Westminster",
                "PO_BOX_NUMBER": "321",
                "DOUBLE_DEPENDENT_LOCALITY": "Double Dependent Locality",
              },
            },
          ],
        }.to_json

        stub_request(:get, "https://api.os.uk/search/places/v1/uprn?key=OS_DATA_KEY&uprn=123456781234")
          .to_return(status: 200, body:, headers: {})
        stub_request(:get, "https://api.os.uk/search/places/v1/uprn?key=OS_DATA_KEY&uprn=123")
          .to_return(status: 500, body: "{}", headers: {})

        allow(logger).to receive(:warn).and_return(nil)
      end

      it "correctly sets address if uprn is not given" do
        lettings_log_xml.at_xpath("//xmlns:UPRN").content = ""
        lettings_log_service.send(:create_log, lettings_log_xml)

        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)
        expect(lettings_log&.uprn_known).to eq(0) # no
        expect(lettings_log&.uprn).to be_nil
        expect(lettings_log&.address_line1).to eq("address 1")
        expect(lettings_log&.address_line2).to eq("address 2")
        expect(lettings_log&.town_or_city).to eq("towncity")
        expect(lettings_log&.county).to eq("county")
        expect(lettings_log&.postcode_full).to eq("A1 1AA")
      end

      it "prioritises address and doesn't set UPRN if both address and UPRN is given" do
        lettings_log_service.send(:create_log, lettings_log_xml)

        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)
        expect(lettings_log&.uprn_known).to eq(0) # no
        expect(lettings_log&.uprn).to be_nil
        expect(lettings_log&.uprn_confirmed).to eq(0)
        expect(lettings_log&.address_line1).to eq("address 1")
        expect(lettings_log&.address_line2).to eq("address 2")
        expect(lettings_log&.town_or_city).to eq("towncity")
        expect(lettings_log&.county).to eq("county")
        expect(lettings_log&.postcode_full).to eq("A1 1AA")
      end

      it "correctly sets address and uprn if uprn is given and address isn't given" do
        lettings_log_xml.at_xpath("//xmlns:AddressLine1").content = ""
        lettings_log_xml.at_xpath("//xmlns:AddressLine2").content = ""
        lettings_log_xml.at_xpath("//xmlns:TownCity").content = ""
        lettings_log_xml.at_xpath("//xmlns:County").content = ""
        lettings_log_service.send(:create_log, lettings_log_xml)

        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)
        expect(lettings_log&.uprn_known).to eq(1)
        expect(lettings_log&.uprn).to eq("123456781234")
        expect(lettings_log&.address_line1).to eq("321")
        expect(lettings_log&.address_line2).to eq("Double Dependent Locality")
        expect(lettings_log&.town_or_city).to eq("Westminster")
        expect(lettings_log&.postcode_full).to eq("LS16 6FT")
        expect(lettings_log&.la).to eq("E08000035")
      end

      it "correctly sets address and uprn if uprn is given but not recognised" do
        lettings_log_xml.at_xpath("//xmlns:UPRN").content = "123"

        lettings_log_service.send(:create_log, lettings_log_xml)

        lettings_log = LettingsLog.find_by(old_id: lettings_log_id)
        expect(lettings_log&.uprn_known).to eq(0)
        expect(lettings_log&.uprn).to be_nil
        expect(lettings_log&.address_line1).to eq("address 1")
        expect(lettings_log&.address_line2).to eq("address 2")
        expect(lettings_log&.town_or_city).to eq("towncity")
        expect(lettings_log&.county).to eq("county")
        expect(lettings_log&.postcode_full).to eq("A1 1AA")
        expect(lettings_log&.la).to eq("E06000047")
      end
    end
  end
end
