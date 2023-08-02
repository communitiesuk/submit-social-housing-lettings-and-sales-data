require "rails_helper"

RSpec.describe Imports::ImportReportService do
  subject(:report_service) { described_class.new(storage_service, old_organisation_ids) }

  let(:storage_service) { instance_double(Storage::S3Service) }

  context "when all organisations have data coordinators" do
    let(:organisation) { create(:organisation, old_visible_id: "1") }
    let(:old_organisation_ids) { [organisation.old_visible_id] }

    before do
      create(:user, :data_coordinator, organisation:)
    end

    it "writes an empty organisations without a data coordinators report" do
      expect(storage_service).to receive(:write_file).with("OrganisationsWithoutDataCoordinators_report_suffix.csv", "\uFEFFOrganisation ID,Old Organisation ID,Organisation Name\n")

      report_service.create_report("report_suffix")
    end
  end

  context "when some organisations have no data coordinators" do
    let(:organisation) { create(:organisation, old_visible_id: "") }
    let(:organisation2) { create(:organisation, old_visible_id: "2") }
    let(:organisation3) { create(:organisation, old_visible_id: "3") }
    let(:old_organisation_ids) { [organisation.old_visible_id, organisation2.old_visible_id, organisation3.old_visible_id] }

    before do
      create(:user, :data_coordinator, organisation:)
    end

    it "writes an empty organisations without a data coordinators report" do
      expect(storage_service).to receive(:write_file).with("OrganisationsWithoutDataCoordinators_report_suffix.csv", "\uFEFFOrganisation ID,Old Organisation ID,Organisation Name\n#{organisation2.id},2,#{organisation2.name}\n#{organisation3.id},3,#{organisation3.name}\n")

      report_service.create_report("report_suffix")
    end
  end
end
