require "rails_helper"
require "rake"

RSpec.describe "log_variable_definitions" do
  describe ":add_variable_definitions", type: :task do
    subject(:task) { Rake::Task["data_import:add_variable_definitions"] }

    let(:path) { "spec/fixtures/variable_definitions" }

    before do
      Rake.application.rake_require("tasks/log_variable_definitions")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    it "adds CsvVariableDefinition records from each file in the specified directory" do
      expect { task.invoke(path) }.to change(CsvVariableDefinition, :count).by(419)
    end

    it "handles an empty directory without errors" do
      empty_path = "spec/fixtures/empty_directory"
      FileUtils.mkdir_p(empty_path)
      expect { task.invoke(empty_path) }.not_to raise_error
      expect(CsvVariableDefinition.count).to eq(0)
    end

    it "does not create duplicate records if run multiple times" do
      CsvVariableDefinition.delete_all
      initial_count = CsvVariableDefinition.count

      task.invoke(path)
      first_run_count = CsvVariableDefinition.count

      task.invoke(path)
      second_run_count = CsvVariableDefinition.count

      expect(first_run_count).to eq(initial_count + 419)
      expect(second_run_count).to eq(first_run_count)
    end
  end
end
