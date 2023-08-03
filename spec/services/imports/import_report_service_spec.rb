require "rails_helper"

RSpec.describe Imports::ImportReportService do
  subject(:report_service) { described_class.new(storage_service, institutions_csv) }

  let(:storage_service) { instance_double(Storage::S3Service) }

  describe "#generate_missing_data_coordinators_report" do
    context "when all organisations have data coordinators" do
      let!(:organisation) { create(:organisation, old_visible_id: "1", name: "org1") }
      let(:institutions_csv) { CSV.parse("Institution name,Id,Old Completed lettings logs,Old In progress lettings logs,Old Completed sales logs,Old In progress sales logs\norg1,1,2,1,4,3", headers: true) }

      before do
        create(:user, :data_coordinator, organisation:)
      end

      it "writes an empty organisations without a data coordinators report" do
        expect(storage_service).to receive(:write_file).with("OrganisationsWithoutDataCoordinators_report_suffix.csv", "\uFEFFOrganisation ID,Old Organisation ID,Organisation Name\n")

        report_service.generate_missing_data_coordinators_report("report_suffix")
      end
    end

    context "when some organisations have no data coordinators" do
      let!(:organisation) { create(:organisation, old_visible_id: "1", name: "org1") }
      let!(:organisation2) { create(:organisation, old_visible_id: "2", name: "org2") }
      let!(:organisation3) { create(:organisation, old_visible_id: "3", name: "org3") }
      let(:institutions_csv) { CSV.parse("Institution name,Id,Old Completed lettings logs,Old In progress lettings logs,Old Completed sales logs,Old In progress sales logs\norg1,1,2,1,4,3\norg2,2,5,6,5,7\norg3,3,5,6,5,7", headers: true) }

      before do
        create(:user, :data_coordinator, organisation:)
      end

      it "writes an empty organisations without a data coordinators report" do
        expect(storage_service).to receive(:write_file).with("OrganisationsWithoutDataCoordinators_report_suffix.csv", "\uFEFFOrganisation ID,Old Organisation ID,Organisation Name\n#{organisation2.id},2,org2\n#{organisation3.id},3,org3\n")

        report_service.generate_missing_data_coordinators_report("report_suffix")
      end
    end

    context "when organisation has an inactive data coordinator" do
      let!(:organisation) { create(:organisation, old_visible_id: "1", name: "org1") }
      let(:institutions_csv) { CSV.parse("Institution name,Id,Old Completed lettings logs,Old In progress lettings logs,Old Completed sales logs,Old In progress sales logs\norg1,1,2,1,4,3", headers: true) }

      before do
        create(:user, :data_coordinator, organisation:, active: false)
      end

      it "includes that organisation in the data coordinators report" do
        expect(storage_service).to receive(:write_file).with("OrganisationsWithoutDataCoordinators_report_suffix.csv", "\uFEFFOrganisation ID,Old Organisation ID,Organisation Name\n#{organisation.id},1,org1\n")

        report_service.generate_missing_data_coordinators_report("report_suffix")
      end
    end
  end

  describe "#generate_logs_report" do
    let(:institutions_csv) { CSV.parse("Institution name,Id,Old Completed lettings logs,Old In progress lettings logs,Old Completed sales logs,Old In progress sales logs\norg1,1,2,1,4,3\norg2,2,5,6,5,7", headers: true) }

    before do
      create(:organisation, old_visible_id: "1", name: "org1")
      create(:organisation, old_visible_id: "2", name: "org2")
    end

    it "generates a report with imported logs" do
      expect(storage_service).to receive(:write_file).with("MigratedLogsReport_report_suffix.csv", "\uFEFFInstitution name,Id,Old Completed lettings logs,Old In progress lettings logs,Old Completed sales logs,Old In progress sales logs,New Completed lettings logs,New In Progress lettings logs,New Completed sales logs,New In Progress sales logs\norg1,1,2,1,4,3,0,0,0,0\norg2,2,5,6,5,7,0,0,0,0\n")
      report_service.generate_logs_report("report_suffix")
    end
  end
end
