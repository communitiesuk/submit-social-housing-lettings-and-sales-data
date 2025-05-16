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
    let!(:organisation_la) { create(:organisation, id: 234, provider_type: "LA") }
    let!(:organisation_prp_non_profit) { create(:organisation, id: 750, provider_type: "PRP") }
    let!(:organisation_prp_profit) { create(:organisation, id: 642, provider_type: "PRP") }
    let(:csv_path) { Rails.root.join("spec/fixtures/files/organisations_group_profit_status_valid.csv") }

    it "updates an organisation profit status field" do
      expect {
        task.invoke(csv_path.to_s)
      }
        .to change { organisation_la.reload.profit_status }.to("local_authority")
        .and change { organisation_prp_non_profit.reload.profit_status }.to("non_profit")
        .and change { organisation_prp_profit.reload.profit_status }.to("profit")
    end

    it "updates an organisation group fields" do
      task.invoke(csv_path.to_s)
      organisation_la.reload
      organisation_prp_non_profit.reload
      organisation_prp_profit.reload

      expect(organisation_la.group).to eq(2)
      expect(organisation_la.group_member).to be_truthy
      expect(organisation_la.group_member_id).to eq(organisation_la.id)

      expect(organisation_prp_non_profit.group).to eq(2)
      expect(organisation_prp_non_profit.group_member).to be_truthy
      expect(organisation_prp_non_profit.group_member_id).to eq(organisation_prp_non_profit.id)

      expect(organisation_prp_profit.group).to be_nil
      expect(organisation_prp_profit.group_member).to be_falsy
      expect(organisation_prp_profit.group_member_id).to be_nil
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
