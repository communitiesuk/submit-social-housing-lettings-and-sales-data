require "rails_helper"
require "rake"

RSpec.describe "generate_sales_documentation" do
  describe ":add_numeric_sales_validations", type: :task do
    subject(:task) { Rake::Task["generate_sales_documentation:add_numeric_sales_validations"] }

    before do
      Timecop.freeze(Time.zone.local(2025, 1, 1))
      Singleton.__init__(FormHandler)
      allow(FormHandler.instance).to receive(:forms).and_return({ "current_sales" => FormHandler.instance.forms["current_sales"], "previous_sales" => "2023_form", "next_sales" => "2025_form" })
      Rake.application.rake_require("tasks/generate_sales_documentation")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    after do
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    context "when the rake task is run" do
      it "creates new validation documentation records" do
        allow(FormHandler.instance.forms).to receive(:[]).with("current_sales").and_return(FormHandler.instance.forms["current_sales"])

        expect { task.invoke(2024) }.to change(LogValidation, :count)
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
        expect(any_min_validation.log_type).to eq("sales")
      end

      it "skips if the validation already exists in the database" do
        task.invoke(2024)
        expect { task.invoke(2024) }.not_to change(LogValidation, :count)
      end

      context "with no year given" do
        it "raises an error" do
          expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake generate_sales_documentation:add_numeric_sales_validations['year']")
        end
      end

      context "with an invalid year given" do
        it "raises an error" do
          expect { task.invoke("abc") }.to raise_error(RuntimeError, "No form found for given year")
        end
      end

      context "with a year for non existing form" do
        it "raises an error" do
          expect { task.invoke("2022") }.to raise_error(RuntimeError, "No form found for given year")
        end
      end
    end
  end

  describe ":describe_sales_validations", type: :task do
    subject(:task) { Rake::Task["generate_sales_documentation:describe_sales_validations"] }

    let(:documentation_generator) { instance_double(DocumentationGenerator, describe_bu_validations: nil, get_all_sales_methods: []) }
    let(:client) { instance_double(OpenAI::Client) }

    before do
      allow(OpenAI::Client).to receive(:new).and_return(client)
      allow(DocumentationGenerator).to receive(:new).and_return(documentation_generator)
      Timecop.freeze(Time.zone.local(2025, 1, 1))
      Singleton.__init__(FormHandler)
      allow(FormHandler.instance).to receive(:forms).and_return({ "current_sales" => "2024_form", "previous_sales" => "2023_form", "next_sales" => "2025_form" })
      Rake.application.rake_require("tasks/generate_sales_documentation")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    after do
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    context "with a year given" do
      it "gets the correct form for next year" do
        allow(FormHandler.instance.forms).to receive(:[]).with("next_sales").and_return("2025_form")
        expect(documentation_generator).to receive(:describe_hard_validations).with(client, "2025_form", anything, anything, "sales")

        task.invoke("2025")
      end

      it "gets the correct form for current year" do
        allow(FormHandler.instance.forms).to receive(:[]).with("current_sales").and_return("2024_form")
        expect(documentation_generator).to receive(:describe_hard_validations).with(client, "2024_form", anything, anything, "sales")
        task.invoke("2024")
      end
    end

    context "with no year given" do
      it "raises an error" do
        expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake generate_sales_documentation:describe_sales_validations['year']")
      end
    end

    context "with an invalid year given" do
      it "raises an error" do
        expect { task.invoke("abc") }.to raise_error(RuntimeError, "No form found for given year")
      end
    end

    context "with a year for non existing form" do
      it "raises an error" do
        expect { task.invoke("2022") }.to raise_error(RuntimeError, "No form found for given year")
      end
    end
  end

  describe ":describe_bu_sales_validations", type: :task do
    subject(:task) { Rake::Task["generate_sales_documentation:describe_bu_sales_validations"] }

    let(:documentation_generator) { instance_double(DocumentationGenerator, describe_bu_validations: nil) }
    let(:client) { instance_double(OpenAI::Client) }

    before do
      allow(OpenAI::Client).to receive(:new).and_return(client)
      allow(DocumentationGenerator).to receive(:new).and_return(documentation_generator)
      Timecop.freeze(Time.zone.local(2025, 1, 1))
      Singleton.__init__(FormHandler)
      allow(FormHandler.instance).to receive(:forms).and_return({ "current_sales" => "2024_form", "previous_sales" => "2023_form", "next_sales" => "2025_form" })
      Rake.application.rake_require("tasks/generate_sales_documentation")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    after do
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    context "with a year given" do
      it "gets the correct form for next year" do
        allow(FormHandler.instance.forms).to receive(:[]).with("next_sales").and_return("2025_form")
        expect(documentation_generator).to receive(:describe_bu_validations).with(client, "2025_form", anything, anything, anything, anything, "sales")

        task.invoke("2025")
      end

      it "gets the correct form for current year" do
        allow(FormHandler.instance.forms).to receive(:[]).with("current_sales").and_return("2024_form")
        expect(documentation_generator).to receive(:describe_bu_validations).with(client, "2024_form", anything, anything, anything, anything, "sales")
        task.invoke("2024")
      end
    end

    context "with no year given" do
      it "raises an error" do
        expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake generate_sales_documentation:describe_bu_sales_validations['year']")
      end
    end

    context "with an invalid year given" do
      it "raises an error" do
        expect { task.invoke("abc") }.to raise_error(RuntimeError, "No form found for given year")
      end
    end

    context "with a year for non existing form" do
      it "raises an error" do
        expect { task.invoke("2022") }.to raise_error(RuntimeError, "No form found for given year")
      end
    end
  end

  describe ":describe_soft_sales_validations", type: :task do
    subject(:task) { Rake::Task["generate_sales_documentation:describe_soft_sales_validations"] }

    let(:documentation_generator) { instance_double(DocumentationGenerator, describe_bu_validations: nil, get_soft_sales_methods: []) }
    let(:client) { instance_double(OpenAI::Client) }

    before do
      allow(OpenAI::Client).to receive(:new).and_return(client)
      allow(DocumentationGenerator).to receive(:new).and_return(documentation_generator)
      Timecop.freeze(Time.zone.local(2025, 1, 1))
      Singleton.__init__(FormHandler)
      allow(FormHandler.instance).to receive(:forms).and_return({ "current_sales" => "2024_form", "previous_sales" => "2023_form", "next_sales" => "2025_form" })
      Rake.application.rake_require("tasks/generate_sales_documentation")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    after do
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    context "with a year given" do
      it "gets the correct form for next year" do
        allow(FormHandler.instance.forms).to receive(:[]).with("next_sales").and_return("2025_form")
        expect(documentation_generator).to receive(:describe_soft_validations).with(client, "2025_form", anything, anything, "sales")

        task.invoke("2025")
      end

      it "gets the correct form for current year" do
        allow(FormHandler.instance.forms).to receive(:[]).with("current_sales").and_return("2024_form")
        expect(documentation_generator).to receive(:describe_soft_validations).with(client, "2024_form", anything, anything, "sales")
        task.invoke("2024")
      end
    end

    context "with no year given" do
      it "raises an error" do
        expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake generate_sales_documentation:describe_soft_sales_validations['year']")
      end
    end

    context "with an invalid year given" do
      it "raises an error" do
        expect { task.invoke("abc") }.to raise_error(RuntimeError, "No form found for given year")
      end
    end

    context "with a year for non existing form" do
      it "raises an error" do
        expect { task.invoke("2022") }.to raise_error(RuntimeError, "No form found for given year")
      end
    end
  end
end
