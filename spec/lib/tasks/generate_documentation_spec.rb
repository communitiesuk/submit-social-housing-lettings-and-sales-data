require "rails_helper"
require "rake"

RSpec.describe "generate_documentation" do
  describe ":describe_lettings_validations", type: :task do
    subject(:task) { Rake::Task["generate_documentation:describe_lettings_validations"] }

    let(:client) { instance_double(OpenAI::Client) }
    let(:response) do
      { "choices" => [{ "message" => { "tool_calls" => [{ "function" => { "arguments" =>
              "{\n  \"description\": \"Validates the format.\",\n  \"cases\": [\n    {\n      \"case_description\": \"Previous postcode is known and current postcode is blank\",\n      \"errors\": [\n        {\n          \"error_message\": \"Enter a valid postcode\",\n          \"field\": \"ppostcode_full\"\n        }\n      ],\n      \"validation_type\": \"format\",\n  \"other_validated_models\": \"User\"    }]\n}" } }] } }] }
    end

    before do
      Rake.application.rake_require("tasks/generate_documentation")
      Rake::Task.define_task(:environment)
      task.reenable
      allow(OpenAI::Client).to receive(:new).and_return(client)
      allow(client).to receive(:chat).and_return(response)
    end

    context "when the rake task is run" do
      it "creates new validation documentation records" do
        expect(Rails.logger).to receive(:info).with(/described/).at_least(:once)
        expect { task.invoke }.to change(Validation, :count)
        expect(Validation.where(validation_name: "validate_numeric_min_max").count).to eq(1)
        expect(Validation.where(validation_name: "validate_layear").count).to eq(1)
        any_validation = Validation.first
        expect(any_validation.description).to eq("Validates the format.")
        expect(any_validation.field).to eq("ppostcode_full")
        expect(any_validation.error_message).to eq("Enter a valid postcode")
        expect(any_validation.case).to eq("Previous postcode is known and current postcode is blank")
        expect(any_validation.from).to be_nil
        expect(any_validation.to).to be_nil
        expect(any_validation.validation_type).to eq("format")
        expect(any_validation.hard_soft).to eq("hard")
        expect(any_validation.other_validated_models).to eq("User")
      end

      it "calls openAI client" do
        expect(client).to receive(:chat)
        task.invoke
      end

      it "skips if the validation already exists in the database" do
        task.invoke
        expect { task.invoke }.not_to change(Validation, :count)
      end

      context "when openAI response is not a JSON" do
        let(:response) { "not a JSON" }

        it "raises an error" do
          expect(Rails.logger).to receive(:error).with(/Failed to save/).at_least(:once)
          expect(Rails.logger).to receive(:error).with(/Error/).at_least(:once)
          task.invoke
        end
      end

      context "when openAI response does not have expected fields" do
        let(:response) { { "choices" => [{ "message" => { "tool_calls" => [{ "function" => { "arguments" => "{}" } }] } }] } }

        it "raises an error" do
          expect(Rails.logger).to receive(:error).with(/Failed to save/).at_least(:once)
          expect(Rails.logger).to receive(:error).with(/Error/).at_least(:once)
          task.invoke
        end
      end
    end
  end

  describe ":describe_soft_lettings_validations", type: :task do
    subject(:task) { Rake::Task["generate_documentation:describe_soft_lettings_validations"] }

    let(:client) { instance_double(OpenAI::Client) }
    let(:response) do
      { "choices" => [{ "message" => { "tool_calls" => [{ "function" => { "arguments" =>
              "{\n  \"description\": \"Validates the format.\",\n  \"validation_type\": \"format\",\n  \"other_validated_models\": \"User\"}" } }] } }] }
    end

    before do
      Rake.application.rake_require("tasks/generate_documentation")
      Rake::Task.define_task(:environment)
      task.reenable
      allow(OpenAI::Client).to receive(:new).and_return(client)
      allow(client).to receive(:chat).and_return(response)
    end

    context "when the rake task is run" do
      it "creates new validation documentation records" do
        expect { task.invoke }.to change(Validation, :count)
        expect(Validation.where(validation_name: "rent_in_soft_min_range?").count).to be_positive
        expect(Validation.where(validation_name: "major_repairs_date_in_soft_range?").count).to be_positive
        any_validation = Validation.first
        expect(any_validation.description).to eq("Validates the format.")
        expect(any_validation.field).not_to be_empty
        expect(any_validation.error_message).not_to be_empty
        expect(any_validation.case).to eq("Provided values fulfill the description")
        expect(any_validation.from).not_to be_nil
        expect(any_validation.to).not_to be_nil
        expect(any_validation.validation_type).to eq("format")
        expect(any_validation.hard_soft).to eq("soft")
        expect(any_validation.other_validated_models).to eq("User")
      end

      it "calls openAI client" do
        expect(client).to receive(:chat)
        task.invoke
      end

      it "skips if the validation already exists in the database" do
        task.invoke
        expect { task.invoke }.not_to change(Validation, :count)
      end
    end
  end

  describe ":describe_bu_lettings_validations", type: :task do
    subject(:task) { Rake::Task["generate_documentation:describe_bu_lettings_validations"] }

    let(:client) { instance_double(OpenAI::Client) }
    let(:response) do
      { "choices" => [{ "message" => { "tool_calls" => [{ "function" => { "arguments" =>
              "{\n  \"description\": \"Validates the format.\",\n  \"cases\": [\n    {\n      \"case_description\": \"Previous postcode is known and current postcode is blank\",\n      \"errors\": [\n        {\n          \"error_message\": \"Enter a valid postcode\",\n          \"field\": \"ppostcode_full\"\n        }\n      ],\n      \"validation_type\": \"format\",\n  \"other_validated_models\": \"User\"    }]\n}" } }] } }] }
    end

    before do
      Rake.application.rake_require("tasks/generate_documentation")
      Rake::Task.define_task(:environment)
      task.reenable
      allow(OpenAI::Client).to receive(:new).and_return(client)
      allow(client).to receive(:chat).and_return(response)
    end

    context "when the rake task is run" do
      it "creates new validation documentation records" do
        expect(Rails.logger).to receive(:info).with(/described/).at_least(:once)
        expect { task.invoke }.to change(Validation, :count)
        expect(Validation.where(validation_name: "validate_needs_type_present").count).to eq(2) # for both years
        expect(Validation.where(validation_name: "validate_data_types").count).to eq(2)
        any_validation = Validation.first
        expect(any_validation.description).to eq("Validates the format.")
        expect(any_validation.field).to eq("ppostcode_full")
        expect(any_validation.error_message).to eq("Enter a valid postcode")
        expect(any_validation.case).to eq("Previous postcode is known and current postcode is blank")
        expect(any_validation.from).not_to be_nil
        expect(any_validation.to).not_to be_nil
        expect(any_validation.validation_type).to eq("format")
        expect(any_validation.hard_soft).to eq("hard")
        expect(any_validation.other_validated_models).to eq("User")
      end

      it "calls openAI client" do
        expect(client).to receive(:chat)
        task.invoke
      end

      it "skips if the validation already exists in the database" do
        task.invoke
        expect { task.invoke }.not_to change(Validation, :count)
      end

      context "when openAI response is not a JSON" do
        let(:response) { "not a JSON" }

        it "raises an error" do
          expect(Rails.logger).to receive(:error).with(/Failed to save/).at_least(:once)
          expect(Rails.logger).to receive(:error).with(/Error/).at_least(:once)
          task.invoke
        end
      end

      context "when openAI response does not have expected fields" do
        let(:response) { { "choices" => [{ "message" => { "tool_calls" => [{ "function" => { "arguments" => "{}" } }] } }] } }

        it "raises an error" do
          expect(Rails.logger).to receive(:error).with(/Failed to save/).at_least(:once)
          expect(Rails.logger).to receive(:error).with(/Error/).at_least(:once)
          task.invoke
        end
      end
    end
  end

  describe ":add_numeric_lettings_validations", type: :task do
    subject(:task) { Rake::Task["generate_documentation:add_numeric_lettings_validations"] }

    before do
      Rake.application.rake_require("tasks/generate_documentation")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      it "creates new validation documentation records" do
        expect { task.invoke }.to change(Validation, :count)
        expect(Validation.where(validation_name: "minimum").count).to be_positive
        expect(Validation.where(validation_name: "range").count).to be_positive
        any_min_validation = Validation.where(validation_name: "minimum").first
        expect(any_min_validation.description).to include("Field value is lower than the minimum value")
        expect(any_min_validation.field).not_to be_empty
        expect(any_min_validation.error_message).to include("must be at least")
        expect(any_min_validation.case).to include("Field value is lower than the minimum value")
        expect(any_min_validation.from).to be_nil
        expect(any_min_validation.to).to be_nil
        expect(any_min_validation.validation_type).to eq("minimum")
        expect(any_min_validation.hard_soft).to eq("hard")
        expect(any_min_validation.other_validated_models).to be_nil
      end

      it "skips if the validation already exists in the database" do
        task.invoke
        expect { task.invoke }.not_to change(Validation, :count)
      end
    end
  end
end
