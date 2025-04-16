require "rails_helper"

RSpec.describe OrganisationNameChangesController, type: :controller do
  let(:organisation) { create(:organisation) }

  describe "GET #change_name" do
    it "assigns previous name changes" do
      create(:organisation_name_change, organisation:, name: "Old Name", startdate: 1.day.ago)
      get :change_name, params: { id: organisation.id }
      expect(controller.instance_variable_get(:@previous_name_changes)).to eq(organisation.name_changes_with_dates)
    end
  end

  describe "POST #create" do
    let(:params) do
      {
        organisation_name_change: {
          name: "New Name",
          startdate: 1.day.from_now,
          immediate_change: false,
        },
      }
    end

    it "creates a new organisation name change with valid params" do
      expect {
        post :create, params: { id: organisation.id }.merge(params)
      }.to change(OrganisationNameChange, :count).by(1)

      expect(response).to redirect_to(organisation_path(organisation))
      expect(flash[:notice]).to eq("Name change scheduled for #{1.day.from_now.to_date.to_formatted_s(:govuk_date)}.")
    end

    it "creates an immediate name change when immediate_change is true" do
      params[:organisation_name_change][:immediate_change] = true
      params[:organisation_name_change].delete(:startdate)

      expect {
        post :create, params: { id: organisation.id }.merge(params)
      }.to change(OrganisationNameChange, :count).by(1)

      expect(response).to redirect_to(organisation_path(organisation))
      expect(flash[:notice]).to eq("Name change saved successfully.")
    end
  end
end
