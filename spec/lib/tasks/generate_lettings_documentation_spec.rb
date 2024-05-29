require "rails_helper"
require "rake"

RSpec.describe "generate_lettings_documentation" do
  describe ":add_numeric_lettings_validations", type: :task do
    subject(:task) { Rake::Task["generate_lettings_documentation:add_numeric_lettings_validations"] }

    before do
      Rake.application.rake_require("tasks/generate_lettings_documentation")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      it "creates new validation documentation records" do
        expect { task.invoke }.to change(LogValidation, :count)
        expect(LogValidation.where(validation_name: "minimum").count).to be_positive
        expect(LogValidation.where(validation_name: "range").count).to be_positive
        any_min_validation = LogValidation.where(validation_name: "minimum").first
        expect(any_min_validation.description).to include("Field value is lower than the minimum value")
        expect(any_min_validation.field).not_to be_empty
        expect(any_min_validation.error_message).to include("must be at least")
        expect(any_min_validation.case).to include("Field value is lower than the minimum value")
        expect(any_min_validation.from).to be_nil
        expect(any_min_validation.to).to be_nil
        expect(any_min_validation.validation_type).to eq("minimum")
        expect(any_min_validation.hard_soft).to eq("hard")
        expect(any_min_validation.other_validated_models).to be_nil
        expect(any_min_validation.log_type).to eq("lettings")
      end

      it "skips if the validation already exists in the database" do
        task.invoke
        expect { task.invoke }.not_to change(LogValidation, :count)
      end
    end
  end
end
