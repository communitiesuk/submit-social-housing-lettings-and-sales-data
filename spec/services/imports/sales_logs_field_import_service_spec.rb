require "rails_helper"

RSpec.describe Imports::SalesLogsFieldImportService do
  subject(:import_service) { described_class.new(storage_service, logger) }

  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:logger) { instance_double(ActiveSupport::Logger) }

  let(:fixture_directory) { "spec/fixtures/imports/sales_logs" }
  let(:sales_log_filename) { "shared_ownership_sales_log" }
  let(:sales_log_file) { File.open("#{fixture_directory}/#{sales_log_filename}.xml") }
  let(:sales_log_xml) { Nokogiri::XML(sales_log_file) }
  let(:organisation) { create(:organisation, old_visible_id: "1", old_org_id: "7c5bd5fb549c09a2c55d7cb90d7ba84927e64618") }
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
        expect(logger).to receive(:info).with("sales log #{sales_log.id}'s owning_organisation_id value has been set to #{organisation.id}")
        expect { import_service.send(:update_field, field, remote_folder) }
          .to(change { sales_log.reload.owning_organisation_id }.from(nil).to(organisation.id))
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

  context "when updating old_form_id" do
    let(:field) { "old_form_id" }
    let(:sales_log_filename) { "shared_ownership_sales_log" }

    context "when the sales log has no offered value" do
      let(:sales_log) { SalesLog.find_by(old_id: sales_log_filename) }

      before do
        Imports::SalesLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        sales_log_file.rewind
        sales_log.update!(old_form_id: nil)
      end

      it "updates the sales_log old_form_id value" do
        expect(logger).to receive(:info).with("sales log #{sales_log.id}'s old_form_id value has been set to 300204")
        expect { import_service.send(:update_field, field, remote_folder) }
          .to(change { sales_log.reload.old_form_id }.from(nil).to(300_204))
      end
    end

    context "when the sales log has a different offered value" do
      let(:sales_log) { SalesLog.find_by(old_id: sales_log_filename) }

      before do
        Imports::SalesLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
        sales_log_file.rewind
        sales_log.update!(old_form_id: 123)
      end

      it "does not update the sales_log old_form_id value" do
        expect(logger).to receive(:info).with(/sales log \d+ has a value for old_form_id, skipping update/)
        expect { import_service.send(:update_field, field, remote_folder) }
          .not_to(change { sales_log.reload.old_form_id })
      end
    end
  end

  context "when updating created_by" do
    let(:field) { "created_by" }
    let(:sales_log_filename) { "shared_ownership_sales_log" }
    let(:sales_log) { SalesLog.find_by(old_id: sales_log_filename) }
    let(:old_log_id) { sales_log.id }

    before do
      Imports::SalesLogsImportService.new(storage_service, logger).create_logs(fixture_directory)
      old_log_id
      sales_log_file.rewind
      sales_log.update!(created_by: sales_log.owning_organisation.users.first, values_updated_at: nil)
    end

    context "when the sales log has created_by value" do
      it "skips the update" do
        expect(logger).to receive(:info).with(/sales log \d+ has created_by value, skipping update/)
        import_service.send(:update_created_by, sales_log_xml)

        old_sales_log = SalesLog.find(old_log_id)
        expect(old_sales_log).not_to be_nil

        new_sales_log = SalesLog.find_by(old_id: sales_log_filename)
        expect(new_sales_log).to eq(old_sales_log)
        expect(new_sales_log.values_updated_at).to be_nil
      end
    end

    context "when the sales log has no created_by value" do
      before do
        sales_log.update!(created_by: nil)
      end

      it "deletes the existing sales log and creates a new log with correct created_by" do
        expect(logger).to receive(:info).with(/sales log \d+ has been deleted/)
        expect(logger).to receive(:info).with(/sales log "shared_ownership_sales_log" has been reimported with id \d+/)
        import_service.send(:update_created_by, sales_log_xml)

        old_sales_log = SalesLog.find_by(id: old_log_id)
        expect(old_sales_log).to be_nil

        new_sales_log = SalesLog.find_by(old_id: sales_log_filename)
        expect(new_sales_log).not_to eq(old_sales_log)
        expect(new_sales_log.values_updated_at).not_to be_nil
      end

      it "deletes the existing sales log and creates a new log with correct unassigned created_by" do
        sales_log_xml.at_xpath("//meta:owner-user-id").content = "fake_id"

        expect(logger).to receive(:info).with(/sales log \d+ has been deleted/)
        expect(logger).to receive(:info).with(/sales log "shared_ownership_sales_log" has been reimported with id \d+/)
        expect(logger).to receive(:error).with(/Sales log 'shared_ownership_sales_log' belongs to legacy user with owner-user-id: 'fake_id' which cannot be found. Assigning log to 'Unassigned' user./)

        import_service.send(:update_created_by, sales_log_xml)

        old_sales_log = SalesLog.find_by(id: old_log_id)
        expect(old_sales_log).to be_nil

        new_sales_log = SalesLog.find_by(old_id: sales_log_filename)
        expect(new_sales_log).not_to eq(old_sales_log)
        expect(new_sales_log.created_by.name).to eq("Unassigned")
        expect(new_sales_log.values_updated_at).not_to be_nil
      end
    end

    context "and the log was not previously imported" do
      it "logs a warning that the log has not been found in the db" do
        sales_log.destroy!
        expect(logger).to receive(:warn).with("sales log with old id #{sales_log_filename} not found")
        expect { import_service.send(:update_created_by, sales_log_xml) }.not_to change(SalesLog, :count)
      end
    end
  end
end
