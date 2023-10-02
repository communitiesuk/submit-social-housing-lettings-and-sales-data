require "rails_helper"
require "rake"

RSpec.describe "correct_addresses" do
  describe ":send_missing_addresses_lettings_csv", type: :task do
    subject(:task) { Rake::Task["correct_addresses:send_missing_addresses_lettings_csv"] }

    before do
      organisation.users.destroy_all
      Rake.application.rake_require("tasks/send_missing_addresses_csv")
      Rake::Task.define_task(:environment)
      task.reenable

      body_1 = {
        results: [
          {
            DPA: {
              "POSTCODE": "BS1 1AD",
              "POST_TOWN": "Bristol",
              "ORGANISATION_NAME": "Some place",
            },
          },
        ],
      }.to_json

      body_2 = {
        results: [
          {
            DPA: {
              "POSTCODE": "EC1N 2TD",
              "POST_TOWN": "Newcastle",
              "ORGANISATION_NAME": "Some place",
            },
          },
        ],
      }.to_json

      stub_request(:get, "https://api.os.uk/search/places/v1/uprn?key=OS_DATA_KEY&uprn=123")
      .to_return(status: 200, body: body_1, headers: {})

      stub_request(:get, "https://api.os.uk/search/places/v1/uprn?key=OS_DATA_KEY&uprn=12")
      .to_return(status: 200, body: body_2, headers: {})
    end

    context "when the rake task is run" do
      let(:organisation) { create(:organisation, name: "test organisation") }

      before do
        stub_const("MISSING_ADDRESSES_THRESHOLD", 5)
      end

      context "when org has more than 5 missing addresses and data coordinators" do
        let!(:data_coordinator) { create(:user, :data_coordinator, organisation:, email: "data_coordinator1@example.com") }
        let!(:data_coordinator2) { create(:user, :data_coordinator, organisation:, email: "data_coordinator2@example.com") }

        before do
          create(:user, :data_provider, organisation:, email: "data_provider1@example.com")
          create_list(:lettings_log, 7, :imported, startdate: Time.zone.local(2023, 9, 9), address_line1: nil, town_or_city: nil, needstype: 1, old_form_id: "form_1", owning_organisation: organisation, managing_organisation: organisation, created_by: organisation.users.first)
        end

        it "enqueues the job with correct organisations" do
          expect { task.invoke }.to enqueue_job(EmailMissingAddressesCsvJob).with(include(data_coordinator.id, data_coordinator2.id), organisation, "lettings")
        end

        it "prints out the jobs enqueued" do
          expect(Rails.logger).to receive(:info).with(nil)
          expect(Rails.logger).to receive(:info).with("Sending missing lettings addresses CSV for test organisation to data_coordinator1@example.com, data_coordinator2@example.com")
          task.invoke
        end
      end

      context "when org has 5 missing addresses and data providers only" do
        let!(:data_provider) { create(:user, :data_provider, organisation:, email: "data_provider3@example.com") }
        let!(:data_provider2) { create(:user, :data_provider, organisation:, email: "data_provider4@example.com") }

        before do
          create_list(:lettings_log, 5, :imported, startdate: Time.zone.local(2023, 9, 9), address_line1: nil, town_or_city: nil, needstype: 1, old_form_id: "form_2", owning_organisation: organisation, managing_organisation: organisation, created_by: organisation.users.first)
        end

        it "enqueues the job with correct organisations" do
          expect { task.invoke }.to enqueue_job(EmailMissingAddressesCsvJob).with(include(data_provider.id, data_provider2.id), organisation, "lettings")
        end

        it "prints out the jobs enqueued" do
          expect(Rails.logger).to receive(:info).with(nil)
          expect(Rails.logger).to receive(:info).with("Sending missing lettings addresses CSV for test organisation to data_provider3@example.com, data_provider4@example.com")
          task.invoke
        end
      end

      context "when org has less than 5 missing addresses" do
        before do
          create_list(:lettings_log, 3, :imported, startdate: Time.zone.local(2023, 9, 9), address_line1: nil, town_or_city: nil, needstype: 1, old_form_id: "form_2", owning_organisation: organisation, managing_organisation: organisation, created_by: organisation.users.first)
          create_list(:lettings_log, 2, :imported, startdate: Time.zone.local(2023, 9, 9), address_line1: nil, needstype: 1, owning_organisation: organisation, managing_organisation: organisation, created_by: organisation.users.first)
        end

        it "does not enqueue the job with organisations that is missing less addresses than threshold amount" do
          expect { task.invoke }.not_to enqueue_job(EmailMissingAddressesCsvJob)
        end
      end

      context "when org has more than 5 missing town_or_city and data coordinators" do
        let!(:data_coordinator) { create(:user, :data_coordinator, organisation:, email: "data_coordinator1@example.com") }
        let!(:data_coordinator2) { create(:user, :data_coordinator, organisation:, email: "data_coordinator2@example.com") }

        before do
          create(:user, :data_provider, organisation:, email: "data_provider1@example.com")
          create_list(:lettings_log, 7, :imported, startdate: Time.zone.local(2023, 9, 9), address_line1: "exists", town_or_city: nil, needstype: 1, old_form_id: "form_1", owning_organisation: organisation, managing_organisation: organisation, created_by: organisation.users.first)
        end

        it "enqueues the job with correct organisations" do
          expect { task.invoke }.to enqueue_job(EmailMissingAddressesCsvJob).with(include(data_coordinator.id, data_coordinator2.id), organisation, "lettings")
        end

        it "prints out the jobs enqueued" do
          expect(Rails.logger).to receive(:info).with(nil)
          expect(Rails.logger).to receive(:info).with("Sending missing lettings addresses CSV for test organisation to data_coordinator1@example.com, data_coordinator2@example.com")
          task.invoke
        end
      end

      context "when org has 5 missing town or city and data providers only" do
        let!(:data_provider) { create(:user, :data_provider, organisation:, email: "data_provider3@example.com") }
        let!(:data_provider2) { create(:user, :data_provider, organisation:, email: "data_provider4@example.com") }

        before do
          create_list(:lettings_log, 5, :imported, startdate: Time.zone.local(2023, 9, 9), address_line1: "exists", town_or_city: nil, needstype: 1, old_form_id: "form_2", owning_organisation: organisation, managing_organisation: organisation, created_by: organisation.users.first)
        end

        it "enqueues the job with correct organisations" do
          expect { task.invoke }.to enqueue_job(EmailMissingAddressesCsvJob).with(include(data_provider.id, data_provider2.id), organisation, "lettings")
        end

        it "prints out the jobs enqueued" do
          expect(Rails.logger).to receive(:info).with(nil)
          expect(Rails.logger).to receive(:info).with("Sending missing lettings addresses CSV for test organisation to data_provider3@example.com, data_provider4@example.com")
          task.invoke
        end
      end

      context "when org has less than 5 missing town or city" do
        before do
          create_list(:lettings_log, 3, :imported, startdate: Time.zone.local(2023, 9, 9), address_line1: "address", town_or_city: nil, needstype: 1, old_form_id: "form_2", owning_organisation: organisation, managing_organisation: organisation, created_by: organisation.users.first)
          create_list(:lettings_log, 2, :imported, startdate: Time.zone.local(2023, 9, 9), address_line1: "address", needstype: 1, owning_organisation: organisation, managing_organisation: organisation, created_by: organisation.users.first)
        end

        it "does not enqueue the job with organisations that is missing less town or city data than threshold amount" do
          expect { task.invoke }.not_to enqueue_job(EmailMissingAddressesCsvJob)
        end
      end

      context "when org has more than 5 wrong uprn and data coordinators" do
        let!(:data_coordinator) { create(:user, :data_coordinator, organisation:, email: "data_coordinator1@example.com") }
        let!(:data_coordinator2) { create(:user, :data_coordinator, organisation:, email: "data_coordinator2@example.com") }

        before do
          create(:user, :data_provider, organisation:, email: "data_provider1@example.com")
          create_list(:lettings_log, 7, :imported, startdate: Time.zone.local(2023, 9, 9), uprn: "123", town_or_city: "Bristol", needstype: 1, owning_organisation: organisation, managing_organisation: organisation, created_by: organisation.users.first)
        end

        it "enqueues the job with correct organisations" do
          expect { task.invoke }.to enqueue_job(EmailMissingAddressesCsvJob).with(include(data_coordinator.id, data_coordinator2.id), organisation, "lettings")
        end

        it "prints out the jobs enqueued" do
          expect(Rails.logger).to receive(:info).with(nil)
          expect(Rails.logger).to receive(:info).with("Sending missing lettings addresses CSV for test organisation to data_coordinator1@example.com, data_coordinator2@example.com")
          task.invoke
        end
      end

      context "when org has 5 wrong uprn and data providers only" do
        let!(:data_provider) { create(:user, :data_provider, organisation:, email: "data_provider3@example.com") }
        let!(:data_provider2) { create(:user, :data_provider, organisation:, email: "data_provider4@example.com") }

        before do
          create_list(:lettings_log, 5, :imported, startdate: Time.zone.local(2023, 9, 9), uprn: "12", propcode: "12", needstype: 1, owning_organisation: organisation, managing_organisation: organisation, created_by: organisation.users.first)
        end

        it "enqueues the job with correct organisations" do
          expect { task.invoke }.to enqueue_job(EmailMissingAddressesCsvJob).with(include(data_provider.id, data_provider2.id), organisation, "lettings")
        end

        it "prints out the jobs enqueued" do
          expect(Rails.logger).to receive(:info).with(nil)
          expect(Rails.logger).to receive(:info).with("Sending missing lettings addresses CSV for test organisation to data_provider3@example.com, data_provider4@example.com")
          task.invoke
        end
      end

      context "when org has less than 5 wrong uprn" do
        let!(:data_provider) { create(:user, :data_provider, organisation:, email: "data_provider3@example.com") }
        let!(:data_provider2) { create(:user, :data_provider, organisation:, email: "data_provider4@example.com") }

        before do
          create_list(:lettings_log, 3, :imported, startdate: Time.zone.local(2023, 9, 9), uprn: "123", town_or_city: "Bristol", needstype: 1, owning_organisation: organisation, managing_organisation: organisation, created_by: organisation.users.first)
          create_list(:lettings_log, 2, :imported, startdate: Time.zone.local(2023, 9, 9), uprn: "12", tenancycode: "12", needstype: 1, owning_organisation: organisation, managing_organisation: organisation, created_by: organisation.users.first)
        end

        it "enqueues the job with correct organisations" do
          expect { task.invoke }.to enqueue_job(EmailMissingAddressesCsvJob).with(include(data_provider.id, data_provider2.id), organisation, "lettings")
        end

        it "prints out the jobs enqueued" do
          expect(Rails.logger).to receive(:info).with(nil)
          expect(Rails.logger).to receive(:info).with("Sending missing lettings addresses CSV for test organisation to data_provider3@example.com, data_provider4@example.com")
          task.invoke
        end
      end

      context "when org is included in SKIP_UPRN_ISSUE_ORG_IDS list" do
        before do
          create_list(:lettings_log, 5, :imported, startdate: Time.zone.local(2023, 9, 9), uprn: "12", propcode: "12", needstype: 1, owning_organisation: organisation, managing_organisation: organisation, created_by: organisation.users.first)
          allow(ENV).to receive(:[]).with("SKIP_UPRN_ISSUE_ORG_IDS").and_return([organisation.id].to_json)
        end

        it "does not enqueue the job" do
          expect { task.invoke }.not_to enqueue_job(EmailMissingAddressesCsvJob)
        end
      end
    end
  end

  describe ":send_missing_addresses_sales_csv", type: :task do
    subject(:task) { Rake::Task["correct_addresses:send_missing_addresses_sales_csv"] }

    before do
      organisation.users.destroy_all
      Rake.application.rake_require("tasks/send_missing_addresses_csv")
      Rake::Task.define_task(:environment)
      task.reenable

      body_1 = {
        results: [
          {
            DPA: {
              "POSTCODE": "BS1 1AD",
              "POST_TOWN": "Bristol",
              "ORGANISATION_NAME": "Some place",
            },
          },
        ],
      }.to_json

      body_2 = {
        results: [
          {
            DPA: {
              "POSTCODE": "EC1N 2TD",
              "POST_TOWN": "Newcastle",
              "ORGANISATION_NAME": "Some place",
            },
          },
        ],
      }.to_json

      stub_request(:get, "https://api.os.uk/search/places/v1/uprn?key=OS_DATA_KEY&uprn=123")
      .to_return(status: 200, body: body_1, headers: {})

      stub_request(:get, "https://api.os.uk/search/places/v1/uprn?key=OS_DATA_KEY&uprn=12")
      .to_return(status: 200, body: body_2, headers: {})
    end

    context "when the rake task is run" do
      let(:organisation) { create(:organisation, name: "test organisation") }

      before do
        stub_const("MISSING_ADDRESSES_THRESHOLD", 5)
      end

      context "when org has more than 5 missing addresses and data coordinators" do
        let!(:data_coordinator) { create(:user, :data_coordinator, organisation:, email: "data_coordinator1@example.com") }
        let!(:data_coordinator2) { create(:user, :data_coordinator, organisation:, email: "data_coordinator2@example.com") }

        before do
          create(:user, :data_provider, organisation:, email: "data_provider1@example.com")
          create_list(:sales_log, 7, :completed, :imported, saledate: Time.zone.local(2023, 9, 9), address_line1: nil, town_or_city: nil, old_form_id: "form_1", owning_organisation: organisation, created_by: organisation.users.first)
        end

        it "enqueues the job with correct organisations" do
          expect { task.invoke }.to enqueue_job(EmailMissingAddressesCsvJob).with(include(data_coordinator.id, data_coordinator2.id), organisation, "sales")
        end

        it "prints out the jobs enqueued" do
          expect(Rails.logger).to receive(:info).with(nil)
          expect(Rails.logger).to receive(:info).with("Sending missing sales addresses CSV for test organisation to data_coordinator1@example.com, data_coordinator2@example.com")
          task.invoke
        end
      end

      context "when org has 5 missing addresses and data providers only" do
        let!(:data_provider) { create(:user, :data_provider, organisation:, email: "data_provider3@example.com") }
        let!(:data_provider2) { create(:user, :data_provider, organisation:, email: "data_provider4@example.com") }

        before do
          create_list(:sales_log, 5, :completed, :imported, saledate: Time.zone.local(2023, 9, 9), address_line1: nil, town_or_city: nil, old_form_id: "form_2", owning_organisation: organisation, created_by: organisation.users.first)
        end

        it "enqueues the job with correct organisations" do
          expect { task.invoke }.to enqueue_job(EmailMissingAddressesCsvJob).with(include(data_provider.id, data_provider2.id), organisation, "sales")
        end

        it "prints out the jobs enqueued" do
          expect(Rails.logger).to receive(:info).with(nil)
          expect(Rails.logger).to receive(:info).with("Sending missing sales addresses CSV for test organisation to data_provider3@example.com, data_provider4@example.com")
          task.invoke
        end
      end

      context "when org has less than 5 missing addresses" do
        before do
          create_list(:sales_log, 3, :completed, :imported, saledate: Time.zone.local(2023, 9, 9), address_line1: nil, town_or_city: nil, old_form_id: "form_2", owning_organisation: organisation, created_by: organisation.users.first)
          create_list(:sales_log, 2, :completed, :imported, saledate: Time.zone.local(2023, 9, 9), address_line1: nil, owning_organisation: organisation, created_by: organisation.users.first)
        end

        it "does not enqueue the job with organisations that is missing less addresses than threshold amount" do
          expect { task.invoke }.not_to enqueue_job(EmailMissingAddressesCsvJob)
        end
      end

      context "when org has more than 5 missing town_or_city and data coordinators" do
        let!(:data_coordinator) { create(:user, :data_coordinator, organisation:, email: "data_coordinator1@example.com") }
        let!(:data_coordinator2) { create(:user, :data_coordinator, organisation:, email: "data_coordinator2@example.com") }

        before do
          create(:user, :data_provider, organisation:, email: "data_provider1@example.com")
          create_list(:sales_log, 7, :completed, :imported, saledate: Time.zone.local(2023, 9, 9), address_line1: "exists", town_or_city: nil, old_form_id: "form_1", owning_organisation: organisation, created_by: organisation.users.first)
        end

        it "enqueues the job with correct organisations" do
          expect { task.invoke }.to enqueue_job(EmailMissingAddressesCsvJob).with(include(data_coordinator.id, data_coordinator2.id), organisation, "sales")
        end

        it "prints out the jobs enqueued" do
          expect(Rails.logger).to receive(:info).with(nil)
          expect(Rails.logger).to receive(:info).with("Sending missing sales addresses CSV for test organisation to data_coordinator1@example.com, data_coordinator2@example.com")
          task.invoke
        end
      end

      context "when org has 5 missing town or city and data providers only" do
        let!(:data_provider) { create(:user, :data_provider, organisation:, email: "data_provider3@example.com") }
        let!(:data_provider2) { create(:user, :data_provider, organisation:, email: "data_provider4@example.com") }

        before do
          create_list(:sales_log, 5, :completed, :imported, saledate: Time.zone.local(2023, 9, 9), address_line1: "exists", town_or_city: nil, old_form_id: "form_2", owning_organisation: organisation, created_by: organisation.users.first)
        end

        it "enqueues the job with correct organisations" do
          expect { task.invoke }.to enqueue_job(EmailMissingAddressesCsvJob).with(include(data_provider.id, data_provider2.id), organisation, "sales")
        end

        it "prints out the jobs enqueued" do
          expect(Rails.logger).to receive(:info).with(nil)
          expect(Rails.logger).to receive(:info).with("Sending missing sales addresses CSV for test organisation to data_provider3@example.com, data_provider4@example.com")
          task.invoke
        end
      end

      context "when org has less than 5 missing town or city" do
        before do
          create_list(:sales_log, 3, :completed, :imported, saledate: Time.zone.local(2023, 9, 9), address_line1: "address", town_or_city: nil, old_form_id: "form_2", owning_organisation: organisation, created_by: organisation.users.first)
          create_list(:sales_log, 2, :completed, :imported, saledate: Time.zone.local(2023, 9, 9), address_line1: "address", owning_organisation: organisation, created_by: organisation.users.first)
        end

        it "does not enqueue the job with organisations that is missing less town or city data than threshold amount" do
          expect { task.invoke }.not_to enqueue_job(EmailMissingAddressesCsvJob)
        end
      end

      context "when org has more than 5 wrong uprn and data coordinators" do
        let!(:data_coordinator) { create(:user, :data_coordinator, organisation:, email: "data_coordinator1@example.com") }
        let!(:data_coordinator2) { create(:user, :data_coordinator, organisation:, email: "data_coordinator2@example.com") }

        before do
          create(:user, :data_provider, organisation:, email: "data_provider1@example.com")
          create_list(:sales_log, 7, :completed, :imported, saledate: Time.zone.local(2023, 9, 9), uprn_known: 1, uprn: "123", town_or_city: "Bristol", owning_organisation: organisation, created_by: organisation.users.first)
        end

        it "enqueues the job with correct organisations" do
          expect { task.invoke }.to enqueue_job(EmailMissingAddressesCsvJob).with(include(data_coordinator.id, data_coordinator2.id), organisation, "sales")
        end

        it "prints out the jobs enqueued" do
          expect(Rails.logger).to receive(:info).with(nil)
          expect(Rails.logger).to receive(:info).with("Sending missing sales addresses CSV for test organisation to data_coordinator1@example.com, data_coordinator2@example.com")
          task.invoke
        end
      end

      context "when org has 5 wrong uprn and data providers only" do
        let!(:data_provider) { create(:user, :data_provider, organisation:, email: "data_provider3@example.com") }
        let!(:data_provider2) { create(:user, :data_provider, organisation:, email: "data_provider4@example.com") }

        before do
          create_list(:sales_log, 5, :completed, :imported, saledate: Time.zone.local(2023, 9, 9), uprn_known: 1, uprn: "12", purchid: "12", owning_organisation: organisation, created_by: organisation.users.first)
        end

        it "enqueues the job with correct organisations" do
          expect { task.invoke }.to enqueue_job(EmailMissingAddressesCsvJob).with(include(data_provider.id, data_provider2.id), organisation, "sales")
        end

        it "prints out the jobs enqueued" do
          expect(Rails.logger).to receive(:info).with(nil)
          expect(Rails.logger).to receive(:info).with("Sending missing sales addresses CSV for test organisation to data_provider3@example.com, data_provider4@example.com")
          task.invoke
        end
      end

      context "when org has less than 5 wrong uprn" do
        let!(:data_provider) { create(:user, :data_provider, organisation:, email: "data_provider3@example.com") }
        let!(:data_provider2) { create(:user, :data_provider, organisation:, email: "data_provider4@example.com") }

        before do
          create_list(:sales_log, 3, :completed, :imported, saledate: Time.zone.local(2023, 9, 9), uprn_known: 1, uprn: "123", town_or_city: "Bristol", owning_organisation: organisation, created_by: organisation.users.first)
          create_list(:sales_log, 2, :completed, :imported, saledate: Time.zone.local(2023, 9, 9), uprn_known: 1, uprn: "12", purchid: "12", owning_organisation: organisation, created_by: organisation.users.first)
        end

        it "enqueues the job with correct organisations" do
          expect { task.invoke }.to enqueue_job(EmailMissingAddressesCsvJob).with(include(data_provider.id, data_provider2.id), organisation, "sales")
        end

        it "prints out the jobs enqueued" do
          expect(Rails.logger).to receive(:info).with(nil)
          expect(Rails.logger).to receive(:info).with("Sending missing sales addresses CSV for test organisation to data_provider3@example.com, data_provider4@example.com")
          task.invoke
        end
      end

      context "when org is included in SKIP_UPRN_ISSUE_ORG_IDS list" do
        before do
          create_list(:sales_log, 5, :completed, :imported, saledate: Time.zone.local(2023, 9, 9), uprn_known: 1, uprn: "12", purchid: "12", owning_organisation: organisation, created_by: organisation.users.first)
          allow(ENV).to receive(:[]).with("SKIP_UPRN_ISSUE_ORG_IDS").and_return([organisation.id].to_json)
        end

        it "does not enqueue the job" do
          expect { task.invoke }.not_to enqueue_job(EmailMissingAddressesCsvJob)
        end
      end
    end
  end
end
