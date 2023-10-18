require "rails_helper"
require "rake"
RSpec.describe "correct_illness" do
  describe ":create_illness_csv", type: :task do
    subject(:task) { Rake::Task["correct_illness:create_illness_csv"] }

    before do
      organisation.users.destroy_all
      Rake.application.rake_require("tasks/correct_illness_from_csv")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let(:organisation) { create(:organisation, name: "test organisation") }

      context "and organisation ID is provided" do
        it "enqueues the job with correct organisation" do
          expect { task.invoke(organisation.id) }.to enqueue_job(CreateIllnessCsvJob).with(organisation)
        end

        it "prints out the jobs enqueued" do
          expect(Rails.logger).to receive(:info).with(nil)
          expect(Rails.logger).to receive(:info).with("Creating illness CSV for test organisation")
          task.invoke(organisation.id)
        end
      end

      context "when organisation with given ID cannot be found" do
        it "prints out error" do
          expect(Rails.logger).to receive(:error).with("Organisation with ID fake not found")
          task.invoke("fake")
        end
      end

      context "when organisation ID is not given" do
        it "raises an error" do
          expect { task.invoke }.to raise_error(RuntimeError, "Usage: rake correct_illness:create_illness_csv['organisation_id']")
        end
      end
    end
  end

  describe ":correct_illness_from_csv", type: :task do
    def replace_entity_ids(lettings_log, second_lettings_log, third_lettings_log, export_template)
      export_template.sub!(/\{id\}/, lettings_log.id.to_s)
      export_template.sub!(/\{id2\}/, second_lettings_log.id.to_s)
      export_template.sub!(/\{id3\}/, third_lettings_log.id.to_s)
    end

    subject(:task) { Rake::Task["correct_illness:correct_illness_from_csv"] }

    let(:instance_name) { "paas_import_instance" }
    let(:storage_service) { instance_double(Storage::S3Service) }
    let(:env_config_service) { instance_double(Configuration::EnvConfigurationService) }
    let(:paas_config_service) { instance_double(Configuration::PaasConfigurationService) }

    before do
      allow(Storage::S3Service).to receive(:new).and_return(storage_service)
      allow(Configuration::EnvConfigurationService).to receive(:new).and_return(env_config_service)
      allow(Configuration::PaasConfigurationService).to receive(:new).and_return(paas_config_service)
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("IMPORT_PAAS_INSTANCE").and_return(instance_name)
      allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return("dummy")

      Rake.application.rake_require("tasks/correct_illness_from_csv")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let(:illness_csv_path) { "illness_123.csv" }
      let(:wrong_file_path) { "/test/no_csv_here.csv" }
      let!(:lettings_log) do
        create(:lettings_log,
               :completed,
               :with_illness_without_type)
      end

      let!(:second_lettings_log) do
        create(:lettings_log,
               :completed,
               illness: 1,
               illness_type_1: true,
               illness_type_2: true)
      end

      let!(:third_lettings_log) do
        create(:lettings_log,
               :completed,
               illness: 1,
               illness_type_3: true,
               illness_type_4: true)
      end

      before do
        allow(storage_service).to receive(:get_file_io)
        .with("illness_123.csv")
        .and_return(replace_entity_ids(lettings_log, second_lettings_log, third_lettings_log, File.open("./spec/fixtures/files/illness_update.csv").read))
      end

      it "sets illness to yes and sets correct illness type" do
        task.invoke(illness_csv_path)
        lettings_log.reload
        expect(lettings_log.illness).to eq(1)
        expect(lettings_log.illness_type_2).to eq(1)
        %w[illness_type_1
           illness_type_3
           illness_type_4
           illness_type_5
           illness_type_6
           illness_type_7
           illness_type_8
           illness_type_9
           illness_type_10].each do |illness_type|
          expect(lettings_log[illness_type]).to eq(0)
        end
      end

      it "sets illness to no" do
        task.invoke(illness_csv_path)
        second_lettings_log.reload
        expect(second_lettings_log.illness).to eq(2)
        %w[illness_type_1
           illness_type_2
           illness_type_3
           illness_type_4
           illness_type_5
           illness_type_6
           illness_type_7
           illness_type_8
           illness_type_9
           illness_type_10].each do |illness_type|
          expect(second_lettings_log[illness_type]).to eq(nil)
        end
      end

      it "sets illness to don't know" do
        task.invoke(illness_csv_path)
        third_lettings_log.reload
        expect(third_lettings_log.illness).to eq(3)
        %w[illness_type_1
           illness_type_2
           illness_type_3
           illness_type_4
           illness_type_5
           illness_type_6
           illness_type_7
           illness_type_8
           illness_type_9
           illness_type_10].each do |illness_type|
          expect(third_lettings_log[illness_type]).to eq(nil)
        end
      end

      it "logs the progress of the update" do
        expect(Rails.logger).to receive(:info).with("Updated lettings log #{lettings_log.id}, with illness: 1, illness_type_2")
        expect(Rails.logger).to receive(:info).with("Updated lettings log #{second_lettings_log.id}, with illness: 2")
        expect(Rails.logger).to receive(:info).with("Updated lettings log #{third_lettings_log.id}, with illness: 3")
        expect(Rails.logger).to receive(:info).with("Lettings log ID not provided")
        expect(Rails.logger).to receive(:info).with("Could not find a lettings log with id fake_id")

        task.invoke(illness_csv_path)
      end

      it "raises an error when no path is given" do
        expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake correct_illness:correct_illness_from_csv['csv_file_name']")
      end

      it "logs an error if a validation fails" do
        lettings_log.postcode_full = "invalid_format"
        lettings_log.save!(validate: false)
        expect(Rails.logger).to receive(:error).with(/Validation failed for lettings log with ID #{lettings_log.id}: Postcode full/)
        task.invoke(illness_csv_path)
      end
    end
  end
end
