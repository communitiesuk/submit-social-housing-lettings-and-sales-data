require "rails_helper"
require "rake"

RSpec.describe "count_duplicates" do
  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:write_file)
    allow(storage_service).to receive(:get_presigned_url).and_return(test_url)
  end

  describe "count_duplicates:scheme_duplicates_per_org", type: :task do
    subject(:task) { Rake::Task["count_duplicates:scheme_duplicates_per_org"] }

    let(:storage_service) { instance_double(Storage::S3Service) }
    let(:test_url) { "test_url" }

    before do
      Rake.application.rake_require("tasks/count_duplicates")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      context "and there are no duplicate schemes" do
        before do
          create(:organisation)
        end

        it "creates a csv with headers only" do
          expect(storage_service).to receive(:write_file).with(/scheme-duplicates-.*\.csv/, "\uFEFFOrganisation id,Number of duplicate sets,Total duplicate schemes\n")
          expect(Rails.logger).to receive(:info).with("Download URL: #{test_url}")
          task.invoke
        end
      end

      context "and there are duplicate schemes" do
        let(:organisation) { create(:organisation) }
        let(:organisation2) { create(:organisation) }

        before do
          create_list(:scheme, 2, :duplicate, owning_organisation: organisation)
          create_list(:scheme, 3, :duplicate, primary_client_group: "I", owning_organisation: organisation)
          create_list(:scheme, 5, :duplicate, owning_organisation: organisation2)
        end

        it "creates a csv with correct duplicate numbers" do
          expect(storage_service).to receive(:write_file).with(/scheme-duplicates-.*\.csv/, "\uFEFFOrganisation id,Number of duplicate sets,Total duplicate schemes\n#{organisation.id},2,5\n#{organisation2.id},1,5\n")
          expect(Rails.logger).to receive(:info).with("Download URL: #{test_url}")
          task.invoke
        end
      end
    end
  end

  describe "count_duplicates:location_duplicates_per_org", type: :task do
    subject(:task) { Rake::Task["count_duplicates:location_duplicates_per_org"] }

    let(:storage_service) { instance_double(Storage::S3Service) }
    let(:test_url) { "test_url" }

    before do
      Rake.application.rake_require("tasks/count_duplicates")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      context "and there are no duplicate locations" do
        before do
          create(:organisation)
        end

        it "creates a csv with headers only" do
          expect(storage_service).to receive(:write_file).with(/location-duplicates-.*\.csv/, "\uFEFFOrganisation id,Number of duplicate sets,Total duplicate locations\n")
          expect(Rails.logger).to receive(:info).with("Download URL: #{test_url}")
          task.invoke
        end
      end

      context "and there are duplicate locations" do
        let(:organisation) { create(:organisation) }
        let(:scheme) { create(:scheme, owning_organisation: organisation) }
        let(:organisation2) { create(:organisation) }
        let(:scheme2) { create(:scheme, owning_organisation: organisation2) }
        let(:scheme3) { create(:scheme, owning_organisation: organisation2) }

        before do
          create_list(:location, 2, postcode: "A1 1AB", mobility_type: "M", scheme:)
          create_list(:location, 3, postcode: "A1 1AB", mobility_type: "A", scheme:)
          create_list(:location, 5, postcode: "A1 1AB", mobility_type: "M", scheme: scheme2)
          create_list(:location, 2, postcode: "A1 1AB", mobility_type: "M", scheme: scheme3)
        end

        it "creates a csv with correct duplicate numbers" do
          expect(storage_service).to receive(:write_file).with(/location-duplicates-.*\.csv/, "\uFEFFOrganisation id,Number of duplicate sets,Total duplicate locations\n#{organisation.id},2,5\n#{organisation2.id},2,7\n")
          expect(Rails.logger).to receive(:info).with("Download URL: #{test_url}")
          task.invoke
        end
      end
    end
  end
end
