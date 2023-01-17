require "rails_helper"

RSpec.describe FiltersHelper do
  describe "#filter_selected?" do
    context "when no filters are selected" do
      it "returns false for all filters" do
        expect(filter_selected?("status", "completed")).to be_falsey
        expect(filter_selected?("status", "in_progress")).to be_falsey
      end
    end

    context "when the filter is the user filter but session filters is empty" do
      before do
        session[:logs_filters] = {}.to_json
      end

      context "when looking at the all value" do
        it "returns true if no filters have been set yet" do
          expect(filter_selected?("user", :all)).to be true
          expect(filter_selected?("user", :yours)).to be false
        end
      end
    end

    context "when one filter is selected" do
      before do
        session[:logs_filters] = { "status": "in_progress" }.to_json
      end

      it "returns false for non selected filters" do
        expect(filter_selected?("status", "completed")).to be false
      end

      it "returns true for selected filter" do
        expect(filter_selected?("status", "in_progress")).to be true
      end
    end

    context "when support user is using the organisation filter" do
      before do
        session[:logs_filters] = { "organisation": "1" }.to_json
      end

      it "returns true for the parent organisation_select filter" do
        expect(filter_selected?("organisation_select", :specific_org)).to be true
        expect(filter_selected?("organisation_select", :all)).to be false
      end
    end

    context "when support user has not set the organisation_select filter" do
      before do
        session[:logs_filters] = {}.to_json
      end

      it "defaults to all organisations" do
        expect(filter_selected?("organisation_select", :all)).to be true
        expect(filter_selected?("organisation_select", :specific_org)).to be false
      end
    end

    context "when the specific organisation filter is not set" do
      before do
        session[:logs_filters] = { "status" => [""], "years" => [""], "user" => "all" }.to_json
      end

      it "marks the all options as checked" do
        expect(filter_selected?("organisation_select", :all)).to be true
        expect(filter_selected?("organisation_select", :specific_org)).to be false
      end
    end
  end

  describe "#selected_option" do
    before do
      session[:logs_filters] = {}.to_json
    end

    context "when nothing has been selected" do
      it "returns an empty string" do
        expect(selected_option("organisation")).to eq("")
      end
    end
  end

  describe "#organisations_filter_options" do
    let(:parent_organisation) { FactoryBot.create(:organisation, name: "Parent organisation") }
    let(:child_organisation) { FactoryBot.create(:organisation, name: "Child organisation") }

    before do
      FactoryBot.create(:organisation_relationship, parent_organisation:, child_organisation:)
      FactoryBot.create(:organisation, name: "Other organisation", id: 99)
    end

    context "with a support user" do
      let(:user) { FactoryBot.create(:user, :support, organisation: parent_organisation) }

      it "returns a list of all organisations" do
        expect(organisations_filter_options(user)).to eq([
          OpenStruct.new(id: "", name: "Select an option"),
          OpenStruct.new(id: parent_organisation.id, name: "Parent organisation"),
          OpenStruct.new(id: child_organisation.id, name: "Child organisation"),
          OpenStruct.new(id: 99, name: "Other organisation"),
        ])
      end
    end

    context "with a data coordinator user" do
      let(:user) { FactoryBot.create(:user, :data_coordinator, organisation: parent_organisation) }

      it "returns a list of managing agents and your own organisation" do
        expect(organisations_filter_options(user)).to eq([
          OpenStruct.new(id: "", name: "Select an option"),
          OpenStruct.new(id: parent_organisation.id, name: "Parent organisation"),
          OpenStruct.new(id: child_organisation.id, name: "Child organisation"),
        ])
      end
    end
  end
end
