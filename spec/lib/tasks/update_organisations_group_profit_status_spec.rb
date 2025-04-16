require "rails_helper"
require "rake"

RSpec.describe "data_update:update_organisations", type: :task do
  let(:task) { Rake::Task["data_update:update_organisations"] }

  before do
    Rake.application.rake_require("tasks/update_organisations_group_profit_status")
    Rake::Task.define_task(:environment)
    task.reenable
  end

  context "when the CSV file is valid" do
    let!(:organisation) { create(:organisation, id: 234) }
    let(:csv_path) { Rails.root.join("spec/fixtures/files/organisations_group_profit_status_valid.csv") }

    it "updates the organisation fields" do
      expect {
        task.invoke(csv_path.to_s)
      }.to change { organisation.reload.profit_status }.to("local_authority")
                                                       .and change { organisation.reload.group }.to(2)
    end
  end

  context "when the organisation is not found" do
    let(:csv_path) { Rails.root.join("spec/fixtures/files/organisations_group_profit_status_invalid.csv") }

    it "logs a warning" do
      expect(Rails.logger).to receive(:warn).with("Organisation with ID 2000 not found")
      task.invoke(csv_path.to_s)
    end
  end

  context "when the CSV path is not provided" do
    it "logs an error and exits" do
      expect(Rails.logger).to receive(:error).with("Please provide the path to the CSV file. Example: rake data_update:update_organisations[csv_path]")
      expect { task.invoke }.to raise_error(SystemExit)
    end
  end
end
