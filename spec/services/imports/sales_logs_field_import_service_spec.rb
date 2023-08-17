require "rails_helper"

RSpec.describe Imports::SalesLogsFieldImportService do
  subject(:import_service) { described_class.new(storage_service, logger) }

  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:logger) { instance_double(ActiveSupport::Logger) }

  let(:fixture_directory) { "spec/fixtures/imports/sales_logs" }
  let(:sales_log_filename) { "shared_ownership_sales_log" }
  let(:sales_log_file) { File.open("#{fixture_directory}/#{sales_log_filename}.xml") }
  let(:organisation) { create(:organisation, old_visible_id: "1", id: "101") }
  let(:old_user_id) { "c3061a2e6ea0b702e6f6210d5c52d2a92612d2aa" }

  let(:remote_folder) { "sales_logs" }

  before do
    create(:user, old_user_id:, organisation:)

    allow(storage_service)
      .to receive(:list_files)
      .and_return(["#{sales_log_filename}.xml"])
    allow(storage_service)
      .to receive(:get_file_io)
      .with("#{sales_log_filename}.xml")
      .and_return(sales_log_file)
  end

  context "when updating creation method" do
    let(:field) { "creation_method" }
    let(:sales_log) { SalesLog.find_by(old_id: sales_log_filename) }

    before do
      Imports::SalesLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
      sales_log_file.rewind
    end

    context "and the log was manually entered" do
      let(:sales_log_filename) { "shared_ownership_sales_log" }

      it "logs that bulk upload id does not need setting" do
        expect(logger).to receive(:info).with("sales log with old id #{sales_log_filename} entered manually, no need for update")
        expect { import_service.update_field(field, remote_folder) }.not_to(change { sales_log.reload.creation_method })
      end
    end

    context "and the log was bulk uploaded and the creation method is already correct" do
      let(:sales_log_filename) { "shared_ownership_sales_log2" }

      it "logs that bulk upload id does not need setting" do
        expect(logger).to receive(:info).with(/sales log \d+ creation method already set to bulk upload, no need for update/)
        expect { import_service.update_field(field, remote_folder) }.not_to(change { sales_log.reload.creation_method })
      end
    end

    context "and the log was bulk uploaded and the creation method requires updating" do
      let(:sales_log_filename) { "shared_ownership_sales_log2" }

      it "logs that bulk upload id does not need setting" do
        sales_log.creation_method_single_log!
        expect(logger).to receive(:info).with(/sales log \d+ creation method set to bulk upload/)
        expect { import_service.update_field(field, remote_folder) }.to change { sales_log.reload.creation_method }.to "bulk upload"
      end
    end

    context "and the log was not previously imported" do
      let(:sales_log_filename) { "shared_ownership_sales_log" }

      it "logs a warning that the log has not been found in the db" do
        sales_log.destroy!
        expect(logger).to receive(:warn).with("sales log with old id #{sales_log_filename} not found")
        import_service.update_field(field, remote_folder)
      end
    end
  end

  context "when updating owning_organisation_id" do
    let(:field) { "owning_organisation_id" }
    let(:sales_log_filename) { "shared_ownership_sales_log" }

    context "when the sales log has no offered value" do
      let(:sales_log) { SalesLog.find_by(old_id: sales_log_filename) }

      before do
        Imports::SalesLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        sales_log_file.rewind
        sales_log.update!(owning_organisation_id: nil)
      end

      it "updates the sales_log owning_organisation_id value" do
        expect(logger).to receive(:info).with(/sales log \d+'s owning_organisation_id value has been set to 101/)
        expect { import_service.send(:update_field, field, remote_folder) }
          .to(change { sales_log.reload.owning_organisation_id }.from(nil).to(101))
      end
    end

    context "when the sales log has a different offered value" do
      let(:sales_log) { SalesLog.find_by(old_id: sales_log_filename) }

      before do
        Imports::SalesLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        sales_log_file.rewind
        sales_log.update!(owning_organisation_id: organisation.id)
      end

      it "does not update the sales_log owning_organisation_id value" do
        expect(logger).to receive(:info).with(/sales log \d+ has a value for owning_organisation_id, skipping update/)
        expect { import_service.send(:update_field, field, remote_folder) }
          .not_to(change { sales_log.reload.owning_organisation_id })
      end
    end
  end
end
