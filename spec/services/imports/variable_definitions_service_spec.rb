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
      allow(Dir).to receive(:glob).and_return(%w[lettings_download_23_24.csv lettings_download_24_25.csv sales_download_23_24.csv sales_download_24_25.csv sales_download_26_27.csv])
      allow(service).to receive(:process_file)
    end

    it "processes each file in the directory" do
      service.call
      %w[lettings_download_23_24.csv lettings_download_24_25.csv sales_download_23_24.csv sales_download_24_25.csv sales_download_26_27.csv].each do |file|
        expect(service).to have_received(:process_file).with(file)
      end
    end
  end

  describe "#process_file" do
    let(:file) { "spec/fixtures/variable_definitions/lettings_download_23_24.csv" }
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
  end
end
