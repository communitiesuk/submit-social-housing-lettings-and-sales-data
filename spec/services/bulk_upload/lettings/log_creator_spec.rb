require "rails_helper"

RSpec.describe BulkUpload::Lettings::LogCreator do
  subject(:service) { described_class.new(bulk_upload:, path:) }

  let(:owning_org) { create(:organisation, old_visible_id: 123) }
  let(:user) { create(:user, organisation: owning_org) }

  let(:bulk_upload) { create(:bulk_upload, :lettings, user:) }
  let(:path) { file_fixture("2022_23_lettings_bulk_upload.csv") }

  describe "#call" do
    context "when a valid csv with new log" do
      it "creates a new log" do
        expect { service.call }.to change(LettingsLog, :count)
      end

      it "associates log with bulk upload" do
        service.call

        log = LettingsLog.last
        expect(log.bulk_upload).to eql(bulk_upload)
        expect(bulk_upload.lettings_logs).to include(log)
      end
    end

    context "when valid csv with existing log" do
      xit "what should happen?"
    end
  end
end
