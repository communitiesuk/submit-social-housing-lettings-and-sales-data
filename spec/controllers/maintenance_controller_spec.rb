require "rails_helper"

RSpec.describe MaintenanceController do
  let(:user) { FactoryBot.create(:user) }

  describe "GET #service_unavailable" do
    context "when maintenance mode is enabled" do
      it "logs the user out" do
        allow(FeatureToggle).to receive(:service_unavailable?).and_return(true)
        sign_in user
        expect(controller).to be_user_signed_in
        get :service_unavailable
        expect(controller).not_to be_user_signed_in
      end
    end

    context "when maintenance mode is disabled" do
      it "doesn't log the user out" do
        allow(FeatureToggle).to receive(:service_unavailable?).and_return(false)
        sign_in user
        expect(controller).to be_user_signed_in
        get :service_unavailable
        expect(controller).to be_user_signed_in
      end
    end
  end
end
