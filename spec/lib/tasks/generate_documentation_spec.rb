require "rails_helper"
require "rake"

RSpec.describe "generate_documentation" do
  describe ":describe_lettings_validations", type: :task do
    subject(:task) { Rake::Task["generate_documentation:describe_lettings_validations"] }

    let(:client) { instance_double(OpenAI::Client) }
    let(:response) do
      { "choices" => [{ "message" => { "tool_calls" => [{ "function" => { "arguments" => 
              "{\n  \"description\": \"Validates the format.\",\n  \"conditions\": [\n    \"The validation runs if the previous postcode is known.\"\n  ],\n  \"cases\": [\n    {\n      \"case_description\": \"Previous postcode is known and current postcode is blank\",\n      \"errors\": [\n        {\n          \"error_message\": \"Enter a valid postcode\",\n          \"field\": \"ppostcode_full\"\n        }\n      ],\n      \"validation_type\": \"format\"\n    }]\n}" } }] }, }]}
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
end
