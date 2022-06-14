require "rails_helper"
require "rake"

describe "rake core:onboard_organisation", type: :task do
  subject(:task) { Rake::Task["core:onboard_organisation"] }

  before do
    Rake.application.rake_require("tasks/onboard_organisation")
    Rake::Task.define_task(:environment)
    task.reenable
  end

  it "triggers 5 data import tasks with the given arguments" do
    expect(Rake::Task["core:data_import"]).to receive(:invoke).with("organisation", "test_org/institution/")
    expect(Rake::Task["core:data_import"]).to receive(:invoke).with("user", "test_org/user/")
    expect(Rake::Task["core:data_import"]).to receive(:invoke).with("data-protection-confirmation", "test_org/dataprotect/")
    expect(Rake::Task["core:data_import"]).to receive(:invoke).with("organisation-rent-periods", "test_org/rent-period/")
    expect(Rake::Task["core:data_import"]).to receive(:invoke).with("logs", "test_org/logs/")
    
    task.invoke("test_org")
  end 

  context "when there are organisation errors at import" do

    before do
      FactoryBot.create(:organisation, name:"test_org")
      # allow(Rake::Task["core:data_import"]) 
      #   .to receive(:invoke).with("organisation","test_org/institution/")
      #   .and_raise(ActiveRecord::RecordNotUnique)
    end

    it "will halt execution if the organisation fails to import due to an error being raised" do
      expect(Rake::Task["core:data_import"]).to receive(:invoke).with("organisation", "test_org/institution/").and_raise(ActiveRecord::RecordNotUnique)
      expect(Rake::Task["core:data_import"]).to_not receive(:invoke).with("user", "test_org/user/")
      expect(Rake::Task["core:data_import"]).to_not receive(:invoke).with("data-protection-confirmation", "test_org/dataprotect/")
      expect(Rake::Task["core:data_import"]).to_not receive(:invoke).with("organisation-rent-periods", "test_org/rent-period/")
      expect(Rake::Task["core:data_import"]).to_not receive(:invoke).with("logs", "test_org/logs/")
      expect{ task.invoke("test_org") }.to_not raise_error
    end
  end
end