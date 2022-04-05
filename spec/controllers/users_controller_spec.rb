require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let(:params) { { id: other_user.id } }
  let(:user) { FactoryBot.create(:user, :data_coordinator) }
  let(:other_user) { FactoryBot.create(:user, organisation: user.organisation) }

  before do
    sign_in user
  end

  describe "GET #edit_password" do
    it "returns not found" do
      get :edit_password, params: params
      expect(response).to have_http_status(:not_found)
    end
  end
end
