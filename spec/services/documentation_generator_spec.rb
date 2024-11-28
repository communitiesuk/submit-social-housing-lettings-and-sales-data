require "rails_helper"

describe DocumentationGenerator do
  let(:client) { instance_double(OpenAI::Client) }
  let(:response) do
    { "choices" => [{ "message" => { "tool_calls" => [{ "function" => { "arguments" =>
            "{\n  \"description\": \"Validates the format.\",\n  \"cases\": [\n    {\n      \"case_description\": \"Previous postcode is known and current postcode is blank\",\n      \"errors\": [\n        {\n          \"error_message\": \"Enter a valid postcode\",\n          \"field\": \"ppostcode_full\"\n        }\n      ],\n      \"validation_type\": \"format\",\n  \"other_validated_models\": \"User\"    }]\n}" } }] } }] }
  end
  let(:all_validation_methods) { %w[validate_numeric_min_max] }
  let(:all_helper_methods) { [] }
  let(:log_type) { "lettings" }

  before do
    allow(client).to receive(:chat).and_return(response)
  end

  describe ":describe_hard_validations" do
    context "when the service is run with lettings type" do
      let(:log_type) { "lettings" }

      it "creates new validation documentation records" do
        expect(Rails.logger).to receive(:info).with(/described/).at_least(:once)
        expect { described_class.new.describe_hard_validations(client, all_validation_methods, all_helper_methods, log_type) }.to change(LogValidation, :count)
        expect(LogValidation.where(validation_name: "validate_numeric_min_max").count).to eq(1)
        any_validation = LogValidation.first
        expect(any_validation.description).to eq("Validates the format.")
        expect(any_validation.field).to eq("ppostcode_full")
        expect(any_validation.error_message).to eq("Enter a valid postcode")
        expect(any_validation.case).to eq("Previous postcode is known and current postcode is blank")
        expect(any_validation.from).to be_nil
        expect(any_validation.to).to be_nil
        expect(any_validation.validation_type).to eq("format")
        expect(any_validation.hard_soft).to eq("hard")
        expect(any_validation.other_validated_models).to eq("User")
        expect(any_validation.log_type).to eq("lettings")
      end

      it "calls the client" do
        expect(client).to receive(:chat)
        described_class.new.describe_hard_validations(client, all_validation_methods, all_helper_methods, log_type)
      end

      it "skips if the validation already exists in the database" do
        described_class.new.describe_hard_validations(client, all_validation_methods, all_helper_methods, log_type)
        expect { described_class.new.describe_hard_validations(client, all_validation_methods, all_helper_methods, log_type) }.not_to change(LogValidation, :count)
      end

      context "when the response is not a JSON" do
        let(:response) { "not a JSON" }

        it "raises an error" do
          expect(Rails.logger).to receive(:error).with(/Failed to save/).at_least(:once)
          expect(Rails.logger).to receive(:error).with(/Error/).at_least(:once)
          described_class.new.describe_hard_validations(client, all_validation_methods, all_helper_methods, log_type)
        end
      end

      context "when the response does not have expected fields" do
        let(:response) { { "choices" => [{ "message" => { "tool_calls" => [{ "function" => { "arguments" => "{}" } }] } }] } }

        it "raises an error" do
          expect(Rails.logger).to receive(:error).with(/Failed to save/).at_least(:once)
          expect(Rails.logger).to receive(:error).with(/Error/).at_least(:once)
          described_class.new.describe_hard_validations(client, all_validation_methods, all_helper_methods, log_type)
        end
      end
    end

    context "when the service is run with sales type" do
      let(:log_type) { "sales" }

      it "creates new validation documentation records" do
        expect(Rails.logger).to receive(:info).with(/described/).at_least(:once)
        expect { described_class.new.describe_hard_validations(client, all_validation_methods, all_helper_methods, log_type) }.to change(LogValidation, :count)
        expect(LogValidation.where(validation_name: "validate_numeric_min_max").count).to eq(1)
        any_validation = LogValidation.first
        expect(any_validation.description).to eq("Validates the format.")
        expect(any_validation.field).to eq("ppostcode_full")
        expect(any_validation.error_message).to eq("Enter a valid postcode")
        expect(any_validation.case).to eq("Previous postcode is known and current postcode is blank")
        expect(any_validation.from).to be_nil
        expect(any_validation.to).to be_nil
        expect(any_validation.validation_type).to eq("format")
        expect(any_validation.hard_soft).to eq("hard")
        expect(any_validation.other_validated_models).to eq("User")
        expect(any_validation.log_type).to eq("sales")
      end
    end
  end

  describe ":describe_soft_validations" do
    let(:all_validation_methods) { ["rent_soft_validation_triggered?"] }
    let(:response) do
      { "choices" => [{ "message" => { "tool_calls" => [{ "function" => { "arguments" =>
              "{\n  \"description\": \"Validates the format.\",\n  \"validation_type\": \"format\",\n  \"other_validated_models\": \"User\"}" } }] } }] }
    end

    context "when the service is run for lettings" do
      let(:log_type) { "lettings" }

      it "creates new validation documentation records" do
        expect { described_class.new.describe_soft_validations(client, all_validation_methods, all_helper_methods, log_type) }.to change(LogValidation, :count)
        expect(LogValidation.where(validation_name: "rent_soft_validation_triggered?").count).to be_positive
        any_validation = LogValidation.first
        expect(any_validation.description).to eq("Validates the format.")
        expect(any_validation.field).not_to be_empty
        expect(any_validation.error_message).not_to be_empty
        expect(any_validation.case).to eq("Provided values fulfill the description")
        expect(any_validation.from).not_to be_nil
        expect(any_validation.to).not_to be_nil
        expect(any_validation.validation_type).to eq("format")
        expect(any_validation.hard_soft).to eq("soft")
        expect(any_validation.other_validated_models).to eq("User")
        expect(any_validation.log_type).to eq("lettings")
      end

      it "calls the client" do
        expect(client).to receive(:chat)
        described_class.new.describe_soft_validations(client, all_validation_methods, all_helper_methods, log_type)
      end

      it "skips if the validation already exists in the database" do
        described_class.new.describe_soft_validations(client, all_validation_methods, all_helper_methods, log_type)
        expect { described_class.new.describe_soft_validations(client, all_validation_methods, all_helper_methods, log_type) }.not_to change(LogValidation, :count)
      end
    end

    context "when the service is run for sales" do
      let(:log_type) { "sales" }
      let(:all_validation_methods) { ["income2_outside_soft_range_for_ecstat?"] }

      it "creates new validation documentation records" do
        expect { described_class.new.describe_soft_validations(client, all_validation_methods, all_helper_methods, log_type) }.to change(LogValidation, :count)
        expect(LogValidation.where(validation_name: "income2_outside_soft_range_for_ecstat?").count).to be_positive
        any_validation = LogValidation.first
        expect(any_validation.description).to eq("Validates the format.")
        expect(any_validation.field).not_to be_empty
        expect(any_validation.error_message).not_to be_empty
        expect(any_validation.case).to eq("Provided values fulfill the description")
        expect(any_validation.from).not_to be_nil
        expect(any_validation.to).not_to be_nil
        expect(any_validation.validation_type).to eq("format")
        expect(any_validation.hard_soft).to eq("soft")
        expect(any_validation.other_validated_models).to eq("User")
        expect(any_validation.log_type).to eq("sales")
      end
    end
  end

  describe ":describe_bu_validations", type: :task do
    let(:all_validation_methods) { %w[validate_owning_org_data_given] }
    let(:field_mapping_for_errors) { row_parser_class.new.send("field_mapping_for_errors") }

    context "when the service is run for lettings" do
      let(:log_type)  { "lettings" }
      let(:form) { FormHandler.instance.forms[FormHandler.instance.form_name_from_start_year(2023, "lettings")] }
      let(:row_parser_class) { BulkUpload::Lettings::Year2023::RowParser }

      it "creates new validation documentation records" do
        expect(Rails.logger).to receive(:info).with(/described/).at_least(:once)
        expect { described_class.new.describe_bu_validations(client, form, row_parser_class, all_validation_methods, all_helper_methods, field_mapping_for_errors, log_type) }.to change(LogValidation, :count)
        expect(LogValidation.where(validation_name: "validate_owning_org_data_given").count).to eq(1)
        any_validation = LogValidation.first
        expect(any_validation.description).to eq("Validates the format.")
        expect(any_validation.field).to eq("ppostcode_full")
        expect(any_validation.error_message).to eq("Enter a valid postcode")
        expect(any_validation.case).to eq("Previous postcode is known and current postcode is blank")
        expect(any_validation.from).not_to be_nil
        expect(any_validation.to).not_to be_nil
        expect(any_validation.validation_type).to eq("format")
        expect(any_validation.hard_soft).to eq("hard")
        expect(any_validation.other_validated_models).to eq("User")
        expect(any_validation.log_type).to eq("lettings")
      end

      it "calls the client" do
        expect(client).to receive(:chat)
        described_class.new.describe_bu_validations(client, form, row_parser_class, all_validation_methods, all_helper_methods, field_mapping_for_errors, log_type)
      end

      it "skips if the validation already exists in the database" do
        described_class.new.describe_bu_validations(client, form, row_parser_class, all_validation_methods, all_helper_methods, field_mapping_for_errors, log_type)
        expect { described_class.new.describe_bu_validations(client, form, row_parser_class, all_validation_methods, all_helper_methods, field_mapping_for_errors, log_type) }.not_to change(LogValidation, :count)
      end

      context "when the response is not a JSON" do
        let(:response) { "not a JSON" }

        it "raises an error" do
          expect(Rails.logger).to receive(:error).with(/Failed to save/).at_least(:once)
          expect(Rails.logger).to receive(:error).with(/Error/).at_least(:once)
          described_class.new.describe_bu_validations(client, form, row_parser_class, all_validation_methods, all_helper_methods, field_mapping_for_errors, log_type)
        end
      end

      context "when the response does not have expected fields" do
        let(:response) { { "choices" => [{ "message" => { "tool_calls" => [{ "function" => { "arguments" => "{}" } }] } }] } }

        it "raises an error" do
          expect(Rails.logger).to receive(:error).with(/Failed to save/).at_least(:once)
          expect(Rails.logger).to receive(:error).with(/Error/).at_least(:once)
          described_class.new.describe_bu_validations(client, form, row_parser_class, all_validation_methods, all_helper_methods, field_mapping_for_errors, log_type)
        end
      end
    end

    context "when the service is run for sales" do
      let(:log_type)  { "sales" }
      let(:form) { FormHandler.instance.forms[FormHandler.instance.form_name_from_start_year(2023, "sales")] }
      let(:row_parser_class) { BulkUpload::Sales::Year2023::RowParser }

      it "creates new validation documentation records" do
        expect(Rails.logger).to receive(:info).with(/described/).at_least(:once)
        expect { described_class.new.describe_bu_validations(client, form, row_parser_class, all_validation_methods, all_helper_methods, field_mapping_for_errors, log_type) }.to change(LogValidation, :count)
        expect(LogValidation.where(validation_name: "validate_owning_org_data_given").count).to eq(1)
        any_validation = LogValidation.first
        expect(any_validation.description).to eq("Validates the format.")
        expect(any_validation.field).to eq("ppostcode_full")
        expect(any_validation.error_message).to eq("Enter a valid postcode")
        expect(any_validation.case).to eq("Previous postcode is known and current postcode is blank")
        expect(any_validation.from).not_to be_nil
        expect(any_validation.to).not_to be_nil
        expect(any_validation.validation_type).to eq("format")
        expect(any_validation.hard_soft).to eq("hard")
        expect(any_validation.other_validated_models).to eq("User")
        expect(any_validation.log_type).to eq("sales")
      end
    end
  end
end
