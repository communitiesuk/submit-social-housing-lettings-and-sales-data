require "rails_helper"
RSpec.describe Csv::MissingIllnessCsvService do
  let(:organisation) { create(:organisation, name: "Illness org") }
  let(:user) { create(:user, organisation:, email: "testy@example.com") }
  let(:service) { described_class.new(organisation) }

  def replace_entity_ids(lettings_log, export_template)
    export_template.sub!(/\{id\}/, lettings_log.id.to_s)
  end

  describe "#create_illness_csv" do
    context "when the organisation has lettings logs" do
      let!(:lettings_log) do
        create(:lettings_log,
               :setup_completed,
               :with_illness_without_type,
               tenancycode: "tenancycode1",
               propcode: "propcode1",
               startdate: Time.zone.local(2023, 4, 5),
               created_by: user,
               owning_organisation: organisation,
               managing_organisation: organisation,
               old_id: "old_id_1")
      end

      before do
        create(:lettings_log, :setup_completed, :with_illness_without_type, startdate: Time.zone.local(2023, 4, 5), owning_organisation: organisation, managing_organisation: organisation, created_by: user)
        create(:lettings_log, :setup_completed, :with_illness_without_type, startdate: Time.zone.local(2023, 4, 5), old_id: "old_id_3")
        create(:lettings_log, :setup_completed, illness: 0, startdate: Time.zone.local(2023, 4, 5), owning_organisation: organisation, managing_organisation: organisation, created_by: user, old_id: "old_id_4")
        create(:lettings_log, :setup_completed, illness: 1, illness_type_1: true, startdate: Time.zone.local(2023, 4, 5), owning_organisation: organisation, managing_organisation: organisation, created_by: user, old_id: "old_id_5")
        log = build(:lettings_log, :setup_completed, :with_illness_without_type, startdate: Time.zone.local(2021, 4, 5), owning_organisation: organisation, managing_organisation: organisation, created_by: user, old_id: "old_id_2")
        log.save!(validate: false)
      end

      it "returns a csv with relevant logs" do
        illness_csv = replace_entity_ids(lettings_log, File.open("spec/fixtures/files/illness.csv").read)
        csv = service.create_illness_csv
        expect(csv).to eq(illness_csv)
      end
    end

    context "when the organisation does not have relevant lettings logs" do
      it "returns only headers" do
        illness_headers_only_csv = File.open("spec/fixtures/files/empty_illness.csv").read
        csv = service.create_illness_csv
        expect(csv).to eq(illness_headers_only_csv)
      end
    end
  end
end
