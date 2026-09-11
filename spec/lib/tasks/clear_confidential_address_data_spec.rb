require "rails_helper"
require "rake"

RSpec.describe "clear_confidential_address_data" do
  describe ":clear_confidential_address_data", type: :task do
    subject(:task) { Rake::Task["clear_confidential_address_data"] }

    before do
      Rake.application.rake_require("tasks/clear_confidential_address_data")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    let(:owning_organisation) { create(:organisation) }
    let(:scheme) { create(:scheme, sensitive: "Yes", owning_organisation:) }
    let(:non_confidential_scheme) { create(:scheme, sensitive: "No", owning_organisation:) }
    let(:location) { create(:location, scheme:) }

    def create_log_with_address_data(scheme:, location:, startdate:)
      log = create(
        :lettings_log,
        :completed,
        :sh,
        :ignore_validation_errors,
        owning_organisation:,
        managing_organisation: owning_organisation,
        scheme:,
        location:,
        startdate:,
      )
      # Bypass callbacks/validations to simulate a log that already holds property
      # address/UPRN data collected before the confidential address feature existed.
      log.update_columns(
        uprn: "123456789012",
        address_line1: "1 Secret Street",
        town_or_city: "Secretville",
        postcode_known: 1,
        la: "E09000003",
      )
      log
    end

    context "when a confidential-scheme log in 2026/27 has address data" do
      let!(:log) { create_log_with_address_data(scheme:, location:, startdate: Time.zone.local(2026, 5, 1)) }

      it "clears the address and UPRN fields" do
        task.invoke
        log.reload

        expect(log.address_line1).to be_nil
        expect(log.town_or_city).to be_nil
        expect(log.uprn).to be_nil
        expect(log.postcode_known).to be_nil
      end

      it "keeps the log's status unchanged when the location's LA can be inferred" do
        task.invoke
        expect(log.reload.status).to eq("completed")
      end

      it "resolves the local authority from the scheme's location without persisting it" do
        task.invoke
        log.reload

        expect(log.la).to eq(location.location_code)
        expect(log[:la]).to be_nil
        expect(log.is_la_inferred).to be true
      end

      it "does not affect the scheme or location associations" do
        task.invoke
        log.reload

        expect(log.scheme_id).to eq(scheme.id)
        expect(log.location_id).to eq(location.id)
      end

      it "is idempotent" do
        task.invoke
        task.reenable
        expect { task.invoke }.not_to(change { log.reload.updated_at })
      end
    end

    context "when the scheme's location has no resolvable local authority" do
      let!(:log) { create_log_with_address_data(scheme:, location:, startdate: Time.zone.local(2026, 5, 1)) }

      before { location.update_columns(location_code: nil, location_admin_district: nil, is_la_inferred: false) }

      it "clears the address fields and forces the log to in_progress" do
        task.invoke
        log.reload

        expect(log.address_line1).to be_nil
        expect(log.la).to be_nil
        expect(log.status).to eq("in_progress")
      end
    end

    context "when the confidential-scheme log is outside the 2026/27 collection year" do
      let!(:log) { create_log_with_address_data(scheme:, location:, startdate: Time.zone.local(2025, 5, 1)) }

      it "does not clear the address fields" do
        task.invoke
        log.reload

        expect(log.address_line1).to eq("1 Secret Street")
        expect(log.town_or_city).to eq("Secretville")
        expect(log.uprn).to eq("123456789012")
        expect(log.postcode_known).to eq(1)
      end
    end

    context "when the log's scheme is not confidential" do
      let!(:log) { create_log_with_address_data(scheme: non_confidential_scheme, location:, startdate: Time.zone.local(2026, 5, 1)) }

      it "does not clear the address fields" do
        task.invoke
        log.reload

        expect(log.address_line1).to eq("1 Secret Street")
        expect(log.town_or_city).to eq("Secretville")
        expect(log.uprn).to eq("123456789012")
        expect(log.postcode_known).to eq(1)
      end
    end

    context "when a confidential-scheme 2026/27 log has no address data left" do
      let!(:log) do
        create(
          :lettings_log,
          :ignore_validation_errors,
          needstype: 2,
          owning_organisation:,
          managing_organisation: owning_organisation,
          scheme:,
          location:,
          startdate: Time.zone.local(2026, 5, 1),
        )
      end

      it "is not touched" do
        expect { task.invoke }.not_to(change { log.reload.updated_at })
      end
    end
  end
end
