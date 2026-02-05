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
          expect(storage_service).to receive(:write_file).with(/scheme-duplicates-.*\.csv/, satisfy do |s|
            s.start_with?("\uFEFFOrganisation id,Number of duplicate sets,Total duplicate schemes") &&
              s.include?("#{organisation.id},2,5") &&
              s.include?("#{organisation2.id},1,5") &&
              s.count("\n") == 3
          end)
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
          expect(storage_service).to receive(:write_file).with(/location-duplicates-.*\.csv/, "\uFEFFOrganisation id,Duplicate sets within individual schemes,Duplicate locations within individual schemes,All duplicate sets,All duplicates\n")
          expect(Rails.logger).to receive(:info).with("Download URL: #{test_url}")
          task.invoke
        end
      end

      context "and there are duplicate locations" do
        let(:organisation) { create(:organisation) }
        let(:scheme_a) { create(:scheme, :duplicate, owning_organisation: organisation) }
        let(:scheme_b) { create(:scheme, :duplicate, owning_organisation: organisation) }
        let(:scheme_c) { create(:scheme, owning_organisation: organisation) }
        let(:organisation2) { create(:organisation) }
        let(:scheme2) { create(:scheme, owning_organisation: organisation2) }
        let(:scheme3) { create(:scheme, owning_organisation: organisation2) }

        before do
          create_list(:location, 2, postcode: "A1 1AB", mobility_type: "M", scheme: scheme_a) # Location A
          create_list(:location, 1, postcode: "A1 1AB", mobility_type: "A", scheme: scheme_a) # Location B

          create_list(:location, 1, postcode: "A1 1AB", mobility_type: "M", scheme: scheme_b) # Location A
          create_list(:location, 1, postcode: "A1 1AB", mobility_type: "A", scheme: scheme_b) # Location B
          create_list(:location, 2, postcode: "A1 1AB", mobility_type: "N", scheme: scheme_b) # Location C

          create_list(:location, 2, postcode: "A1 1AB", mobility_type: "A", scheme: scheme_c) # Location B

          create_list(:location, 5, postcode: "A1 1AB", mobility_type: "M", scheme: scheme2)
          create_list(:location, 2, postcode: "A1 1AB", mobility_type: "M", scheme: scheme3)
        end

        it "creates a csv with correct duplicate numbers" do
          expect(storage_service).to receive(:write_file).with(/location-duplicates-.*\.csv/, satisfy do |s|
            s.start_with?("\uFEFFOrganisation id,Duplicate sets within individual schemes,Duplicate locations within individual schemes,All duplicate sets,All duplicates") &&
              s.include?("#{organisation.id},3,6,4,9") &&
              s.include?("#{organisation2.id},2,7,2,7") &&
              s.count("\n") == 3
          end)
          expect(Rails.logger).to receive(:info).with("Download URL: #{test_url}")
          task.invoke
        end
      end
    end
  end

  describe "count_duplicates:active_scheme_duplicates_per_org", type: :task do
    subject(:task) { Rake::Task["count_duplicates:active_scheme_duplicates_per_org"] }

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
          create_list(:scheme, 2, :duplicate, :with_location, owning_organisation: organisation)
          create_list(:scheme, 3, :duplicate, :with_location, primary_client_group: "I", owning_organisation: organisation)
          create_list(:scheme, 5, :duplicate, :with_location, owning_organisation: organisation2)
          deactivated_schemes = create_list(:scheme, 2, :duplicate, owning_organisation: organisation)
          deactivated_schemes.each do |scheme|
            create(:scheme_deactivation_period, deactivation_date: Time.zone.yesterday, reactivation_date: nil, scheme:)
          end
        end

        it "creates a csv with correct duplicate numbers" do
          expect(storage_service).to receive(:write_file).with(/scheme-duplicates-.*\.csv/, satisfy do |s|
            s.start_with?("\uFEFFOrganisation id,Number of duplicate sets,Total duplicate schemes") &&
              s.include?("#{organisation.id},2,5") &&
              s.include?("#{organisation2.id},1,5") &&
              s.count("\n") == 3
          end)
          expect(Rails.logger).to receive(:info).with("Download URL: #{test_url}")
          task.invoke
        end
      end
    end
  end

  describe "count_duplicates:active_location_duplicates_per_org", type: :task do
    subject(:task) { Rake::Task["count_duplicates:active_location_duplicates_per_org"] }

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
          expect(storage_service).to receive(:write_file).with(/location-duplicates-.*\.csv/, "\uFEFFOrganisation id,Duplicate sets within individual schemes,Duplicate locations within individual schemes,All duplicate sets,All duplicates\n")
          expect(Rails.logger).to receive(:info).with("Download URL: #{test_url}")
          task.invoke
        end
      end

      context "and there are duplicate locations" do
        let(:organisation) { create(:organisation) }
        let(:scheme_a) { create(:scheme, :duplicate, owning_organisation: organisation) }
        let(:scheme_b) { create(:scheme, :duplicate, owning_organisation: organisation) }
        let(:scheme_c) { create(:scheme, owning_organisation: organisation) }
        let(:organisation2) { create(:organisation) }
        let(:scheme2) { create(:scheme, owning_organisation: organisation2) }
        let(:scheme3) { create(:scheme, owning_organisation: organisation2) }

        before do
          create_list(:location, 2, postcode: "A1 1AB", mobility_type: "M", scheme: scheme_a) # Location A
          create_list(:location, 1, postcode: "A1 1AB", mobility_type: "A", scheme: scheme_a) # Location B

          create_list(:location, 1, postcode: "A1 1AB", mobility_type: "M", scheme: scheme_b) # Location A
          create_list(:location, 1, postcode: "A1 1AB", mobility_type: "A", scheme: scheme_b) # Location B
          create_list(:location, 2, postcode: "A1 1AB", mobility_type: "N", scheme: scheme_b) # Location C

          create_list(:location, 2, postcode: "A1 1AB", mobility_type: "A", scheme: scheme_c) # Location B

          create_list(:location, 5, postcode: "A1 1AB", mobility_type: "M", scheme: scheme2)
          create_list(:location, 2, postcode: "A1 1AB", mobility_type: "M", scheme: scheme3)

          deactivated_locations = create_list(:location, 1, postcode: "A1 1AB", mobility_type: "M", scheme: scheme_b)
          deactivated_locations.each do |location|
            create(:location_deactivation_period, deactivation_date: Time.zone.yesterday, reactivation_date: nil, location:)
          end
        end

        it "creates a csv with correct duplicate numbers" do
          expect(storage_service).to receive(:write_file).with(/location-duplicates-.*\.csv/, satisfy do |s|
            s.start_with?("\uFEFFOrganisation id,Duplicate sets within individual schemes,Duplicate locations within individual schemes,All duplicate sets,All duplicates")
            s.include?("#{organisation.id},3,6,4,9") &&
            s.include?("#{organisation2.id},2,7,2,7") &&
            s.count("\n") == 3
          end)
          expect(Rails.logger).to receive(:info).with("Download URL: #{test_url}")
          task.invoke
        end
      end
    end
  end
end
