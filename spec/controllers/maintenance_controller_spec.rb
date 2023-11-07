require "rails_helper"

RSpec.describe MaintenanceController do
  let(:user) { FactoryBot.create(:user) }

  describe "GET #service_moved" do
    context "when the service has moved" do
      it "logs the user out" do
        allow(FeatureToggle).to receive(:service_moved?).and_return(true)
        sign_in user
        expect(controller).to be_user_signed_in
        get :service_moved
        expect(controller).not_to be_user_signed_in
      end
    end

    context "when the service hasn't moved" do
      it "doesn't log the user out" do
        allow(FeatureToggle).to receive(:service_moved?).and_return(false)
        sign_in user
        expect(controller).to be_user_signed_in
        get :service_moved
        expect(controller).to be_user_signed_in
      end
    end
  end

  describe "GET #service_unavailable" do
    context "when the service is unavailable" do
      it "logs the user out" do
        allow(FeatureToggle).to receive(:service_unavailable?).and_return(true)
        sign_in user
        expect(controller).to be_user_signed_in
        get :service_unavailable
        expect(controller).not_to be_user_signed_in
      end
    end

    context "when the service is available" do
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
