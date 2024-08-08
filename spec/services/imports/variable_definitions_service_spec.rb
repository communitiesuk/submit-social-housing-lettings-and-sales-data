require "rails_helper"

RSpec.describe Imports::VariableDefinitionsService, type: :service do
  let(:path) { "spec/fixtures/variable_definitions" }
  let(:service) { described_class.new(path:) }

  describe "#initialize" do
    it "initializes with the correct path and count" do
      expect(service.path).to eq(path)
      expect(service.count).to eq(0)
    end
  end

  describe "#call" do
    before do
      allow(Dir).to receive(:glob).and_return(%w[lettings_support_download_23_24.csv lettings_support_download_24_25.csv lettings_user_download_23_24.csv lettings_user_download_24_25.csv sales_support_download_23_24.csv sales_support_download_24_25.csv sales_user_download_23_24.csv sales_user_download_24_25.csv])
      allow(service).to receive(:process_file)
    end

    it "processes each file in the directory" do
      service.call
      %w[lettings_support_download_23_24.csv lettings_support_download_24_25.csv lettings_user_download_23_24.csv lettings_user_download_24_25.csv sales_support_download_23_24.csv sales_support_download_24_25.csv sales_user_download_23_24.csv sales_user_download_24_25.csv].each do |file|
        expect(service).to have_received(:process_file).with(file)
      end
    end
  end

  describe "#process_file" do
    let(:file) { "spec/fixtures/variable_definitions/lettings_user_download_23_24.csv" }
    let(:csv_content) { [["id", "Log ID"], ["status", "Status of log"], ["duplicate_set_id", "ID of a set of duplicate logs"]] }

    before do
      allow(CSV).to receive(:foreach).and_yield(csv_content[0]).and_yield(csv_content[1]).and_yield(csv_content[2])
    end

    context "when no existing record" do
      it "creates new records" do
        expect {
          service.send(:process_file, file)
        }.to change(CsvVariableDefinition, :count).by(3)
      end
    end

    context "when existing record with user_type support" do
      let!(:existing_record) { create(:csv_variable_definition, variable: "id", definition: "Log ID", log_type: "lettings", user_type: "support") }

      it "updates the user_type to user" do
        service.send(:process_file, file)
        expect(existing_record.reload.user_type).to eq("user")
      end
    end

    context "when existing record with user_type user" do
      let!(:existing_record) { create(:csv_variable_definition, variable: "id", definition: "Log ID", log_type: "lettings", user_type: "user") }

      it "does not update the user_type" do
        service.send(:process_file, file)
        expect(existing_record.reload.user_type).to eq("user")
      end
    end
  end
end
