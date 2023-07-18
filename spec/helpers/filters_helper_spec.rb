require "rails_helper"

RSpec.describe FiltersHelper do
  describe "#filter_selected?" do
    context "when no filters are selected" do
      it "returns false for all filters" do
        expect(filter_selected?("status", "completed", "lettings_logs")).to be_falsey
        expect(filter_selected?("status", "in_progress", "lettings_logs")).to be_falsey
      end
    end

    context "when the filter is the user filter but session filters is empty" do
      before do
        session[:lettings_logs_filters] = {}.to_json
      end

      context "when looking at the all value" do
        it "returns true if no filters have been set yet" do
          expect(filter_selected?("user", :all, "lettings_logs")).to be true
          expect(filter_selected?("user", :yours, "lettings_logs")).to be false
        end
      end
    end

    context "when one filter is selected" do
      before do
        session[:lettings_logs_filters] = { "status": "in_progress" }.to_json
      end

      it "returns false for non selected filters" do
        expect(filter_selected?("status", "completed", "lettings_logs")).to be false
      end

      it "returns true for selected filter" do
        expect(filter_selected?("status", "in_progress", "lettings_logs")).to be true
      end
    end

    context "when support user is using the organisation filter" do
      before do
        session[:lettings_logs_filters] = { "owning_organisation": "1" }.to_json
      end

      it "returns true for the parent owning_organisation_select filter" do
        expect(filter_selected?("owning_organisation_select", :specific_org, "lettings_logs")).to be true
        expect(filter_selected?("owning_organisation_select", :all, "lettings_logs")).to be false
      end
    end

    context "when support user has not set the owning_organisation_select filter" do
      before do
        session[:lettings_logs_filters] = {}.to_json
      end

      it "defaults to all organisations" do
        expect(filter_selected?("owning_organisation_select", :all, "lettings_logs")).to be true
        expect(filter_selected?("owning_organisation_select", :specific_org, "lettings_logs")).to be false
      end
    end

    context "when the specific owning organisation filter is not set" do
      before do
        session[:lettings_logs_filters] = { "status" => [""], "years" => [""], "user" => "all" }.to_json
      end

      it "marks the all options as checked" do
        expect(filter_selected?("owning_organisation_select", :all, "lettings_logs")).to be true
        expect(filter_selected?("owning_organisation_select", :specific_org, "lettings_logs")).to be false
      end
    end
  end

  describe "#any_filter_selected?" do
    let(:filter_type) { "lettings_logs" }
    let(:result) { any_filter_selected?(filter_type) }
    let(:serialised_filters) { filters&.to_json }
    let(:filters) { nil }

    before do
      session[:lettings_logs_filters] = serialised_filters if serialised_filters
    end

    it "returns false if the session contains no filters" do
      expect(result).to be_falsey
    end

    context "when organisation and user are set to all" do
      let(:filters) { { "owning_organisation_select" => "all", "user" => "all" } }

      it "returns false" do
        expect(result).to be_falsey
      end
    end

    context "when user is set to 'yours'" do
      let(:filters) { { "user" => "yours" } }

      it "returns true" do
        expect(result).to be true
      end
    end

    context "when organisation is filtered" do
      let(:filters) { { "organisation" => 2 } }

      it "returns true" do
        expect(result).to be true
      end
    end

    context "when status is filtered" do
      let(:filters) { { "status" => %w[in_progress] } }

      it "returns true" do
        expect(result).to be true
      end
    end

    context "when collection year is filtered" do
      let(:filters) { { "years" => %w[2023] } }

      it "returns true" do
        expect(result).to be true
      end
    end

    context "when the user is currently in a bulk upload journey" do
      let(:filters) { { "bulk_upload_id" => "3456" } }

      it "returns true" do
        expect(result).to be true
      end
    end

    context "when a range of filters is applied" do
      let(:filters) do
        {
          "user" => "all",
          "status" => %w[in_progress completed],
          "years" => [""],
          "organisation" => 2,
        }
      end

      it "returns true" do
        expect(result).to be true
      end
    end
  end

  describe "#selected_option" do
    before do
      session[:lettings_logs_filters] = {}.to_json
    end

    context "when nothing has been selected" do
      it "returns an empty string" do
        expect(selected_option("organisation", "lettings_logs")).to eq("")
      end
    end
  end

  describe "#owning_organisations_filter_options" do
    let(:parent_organisation) { FactoryBot.create(:organisation, name: "Parent organisation") }
    let(:child_organisation) { FactoryBot.create(:organisation, name: "Child organisation") }

    before do
      FactoryBot.create(:organisation_relationship, parent_organisation:, child_organisation:)
      FactoryBot.create(:organisation, name: "Other organisation", id: 99)
    end

    context "with a support user" do
      let(:user) { FactoryBot.create(:user, :support, organisation: child_organisation) }

      it "returns a list of all organisations" do
        expect(owning_organisations_filter_options(user)).to eq([
          OpenStruct.new(id: "", name: "Select an option"),
          OpenStruct.new(id: parent_organisation.id, name: "Parent organisation"),
          OpenStruct.new(id: child_organisation.id, name: "Child organisation"),
          OpenStruct.new(id: 99, name: "Other organisation"),
        ])
      end
    end

    context "with a data coordinator user" do
      let(:user) { FactoryBot.create(:user, :data_coordinator, organisation: child_organisation) }

      it "returns a list of paret orgs and your own organisation" do
        expect(owning_organisations_filter_options(user)).to eq([
          OpenStruct.new(id: "", name: "Select an option"),
          OpenStruct.new(id: child_organisation.id, name: "Child organisation"),
          OpenStruct.new(id: parent_organisation.id, name: "Parent organisation"),
        ])
      end
    end
  end

  describe "#collection_year_options" do
    it "includes 2023/2024 option" do
      expect(collection_year_options).to eq(
        {
          "2021": "2021/22", "2022": "2022/23", "2023": "2023/24"
        },
      )
    end
  end

  describe "#filters_applied_text" do
    let(:filter_type) { "lettings_logs" }
    let(:result) { filters_applied_text(filter_type) }
    let(:serialised_filters) { filters&.to_json }
    let(:filters) { nil }

    before do
      session[:lettings_logs_filters] = serialised_filters if serialised_filters
    end

    context "when no filters are applied" do
      let(:filters) do
        {
          "user" => "all",
          "status" => [""],
          "years" => [""],
          "organisation" => "all",
        }
      end

      it "returns the correct filters count" do
        expect(result).to eq "No filters applied"
      end
    end

    context "when a range of filters is applied" do
      let(:filters) do
        {
          "user" => "all",
          "status" => %w[in_progress completed],
          "years" => [""],
          "organisation" => 2,
        }
      end

      it "returns the correct filters count" do
        expect(result).to eq "3 filters applied"
      end
    end
  end
end
