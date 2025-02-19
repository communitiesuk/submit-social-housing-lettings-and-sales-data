require "rails_helper"
require "rake"

RSpec.describe "emails" do
  describe ":merge_organisations", type: :task do
    subject(:task) { Rake::Task["merge:merge_organisations"] }

    let(:organisation) { create(:organisation) }
    let(:merging_organisation) { create(:organisation) }

    let(:merge_organisations_service) { Merge::MergeOrganisationsService.new(absorbing_organisation_id: organisation.id, merging_organisation_ids: [merging_organisation.id]) }

    before do
      allow(Merge::MergeOrganisationsService).to receive(:new).and_return(merge_organisations_service)
      allow(merge_organisations_service).to receive(:call).and_return(nil)
      Rake.application.rake_require("tasks/merge_organisations")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      it "raises an error when no parameters are given" do
        expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake merge:merge_organisations[absorbing_organisation_id, merging_organisation_ids, merge_date]")
      end

      it "raises an error when only absorbing organisation is given" do
        expect { task.invoke(1, nil) }.to raise_error(RuntimeError, "Usage: rake merge:merge_organisations[absorbing_organisation_id, merging_organisation_ids, merge_date]")
      end

      it "raises an error when only merging organisations are given" do
        expect { task.invoke(nil, "1 2") }.to raise_error(RuntimeError, "Usage: rake merge:merge_organisations[absorbing_organisation_id, merging_organisation_ids, merge_date]")
      end

      it "raises an error when the merge date given is not valid" do
        expect { task.invoke("3", "1 2", "invalid_date") }.to raise_error(RuntimeError, "Usage: rake merge:merge_organisations[absorbing_organisation_id, merging_organisation_ids, merge_date]. Merge date must be in format YYYY-MM-DD")
      end

      it "runs the service with correct organisation IDs" do
        expect(Merge::MergeOrganisationsService).to receive(:new).with(absorbing_organisation_id: 1, merging_organisation_ids: [2, 3], merge_date: nil).once
        expect(merge_organisations_service).to receive(:call).once
        task.invoke(1, "2 3")
      end

      it "runs the service with correct date when date is given" do
        expect(Merge::MergeOrganisationsService).to receive(:new).with(absorbing_organisation_id: 1, merging_organisation_ids: [2, 3], merge_date: Time.zone.local(2021, 1, 13)).once
        expect(merge_organisations_service).to receive(:call).once
        task.invoke(1, "2 3", "2021-01-13")
      end
    end
  end

  describe ":merge_organisations_into_new_organisation", type: :task do
    subject(:task) { Rake::Task["merge:merge_organisations_into_new_organisation"] }

    let(:organisation) { create(:organisation) }
    let(:merging_organisation) { create(:organisation) }

    let(:merge_organisations_service) { Merge::MergeOrganisationsService.new(absorbing_organisation_id: organisation.id, merging_organisation_ids: [merging_organisation.id]) }

    before do
      allow(Merge::MergeOrganisationsService).to receive(:new).and_return(merge_organisations_service)
      allow(merge_organisations_service).to receive(:call).and_return(nil)
      Rake.application.rake_require("tasks/merge_organisations")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      it "raises an error when no parameters are given" do
        expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake merge:merge_organisations_into_new_organisation[absorbing_organisation_id, merging_organisation_ids, merge_date]")
      end

      it "raises an error when only absorbing organisation is given" do
        expect { task.invoke(1, nil) }.to raise_error(RuntimeError, "Usage: rake merge:merge_organisations_into_new_organisation[absorbing_organisation_id, merging_organisation_ids, merge_date]")
      end

      it "raises an error when only merging organisations are given" do
        expect { task.invoke(nil, "1 2") }.to raise_error(RuntimeError, "Usage: rake merge:merge_organisations_into_new_organisation[absorbing_organisation_id, merging_organisation_ids, merge_date]")
      end

      it "raises an error when the merge date given is not valid" do
        expect { task.invoke("3", "1 2", "invalid_date") }.to raise_error(RuntimeError, "Usage: rake merge:merge_organisations_into_new_organisation[absorbing_organisation_id, merging_organisation_ids, merge_date]. Merge date must be in format YYYY-MM-DD")
      end

      it "runs the service with correct organisation IDs" do
        expect(Merge::MergeOrganisationsService).to receive(:new).with(absorbing_organisation_id: 1, merging_organisation_ids: [2, 3], merge_date: nil, absorbing_organisation_active_from_merge_date: true).once
        expect(merge_organisations_service).to receive(:call).once
        task.invoke(1, "2 3")
      end

      it "runs the service with correct date when date is given" do
        expect(Merge::MergeOrganisationsService).to receive(:new).with(absorbing_organisation_id: 1, merging_organisation_ids: [2, 3], merge_date: Time.zone.local(2021, 1, 13), absorbing_organisation_active_from_merge_date: true).once
        expect(merge_organisations_service).to receive(:call).once
        task.invoke(1, "2 3", "2021-01-13")
      end
    end
  end
end
