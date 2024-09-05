require "rails_helper"

RSpec.describe NotificationsController, type: :request do
  context "when user is signed in as a support user" do
    let(:support_user) { create(:user, :support) }

    before do
      allow(support_user).to receive(:need_two_factor_authentication?).and_return(false)
      sign_in support_user
    end

    describe "#create" do
      let(:request) { post notifications_path, params: params }

      context "with valid parameters" do
        let(:params) { { "notification": { title: "Test Create", show_on_unauthenticated_pages: "1", show_additional_page: "1", link_text: "link", page_content: "page" } } }

        it "creates a new notification with no start date set" do
          request
          notification = Notification.find_by(title: "Test Create")
          expect(notification.show_on_unauthenticated_pages).to be(true)
          expect(notification.show_additional_page).to be(true)
          expect(notification.link_text).to eq("link")
          expect(notification.page_content).to eq("page")
          expect(notification.start_date).to be_nil
        end

        it "redirects to check answers page" do
          request
          notification = Notification.find_by(title: "Test Create")
          expect(response).to redirect_to(notification_check_answers_path(notification))
        end
      end

      context "with invalid parameters" do
        let(:params) { { "notification": { title: "", show_on_unauthenticated_pages: "1" } } }

        it "gives an error response" do
          request
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when show additional page is false" do
        let(:params) { { "notification": { title: "No Additional Page", show_on_unauthenticated_pages: "1", show_additional_page: "0", link_text: "text", page_content: "content" } } }

        it "ignores values for link_text and page_content" do
          request
          notification = Notification.find_by(title: "No Additional Page")
          expect(notification.link_text).to be_nil
          expect(notification.page_content).to be_nil
        end
      end
    end

    describe "#update" do
      let(:notification) { create(:notification, title: "Initial Title", start_date: nil, end_date: nil) }
      let(:request) { patch notification_path(notification), params: params }

      context "when start_now is set to true" do
        let(:params) { { "notification": { start_now: true } } }

        it "sets the start date on the notification" do
          request
          notification.reload
          expect(notification.start_date).not_to be_nil
          expect(notification.start_date).to be < Time.zone.now
        end

        it "redirects to the home page" do
          request
          expect(response).to redirect_to(root_path)
        end
      end

      context "when start_now is not set" do
        let(:params) { { "notification": { title: "Updated Title", show_on_unauthenticated_pages: "1" } } }

        it "sets the relevant values on the notification" do
          request
          notification.reload
          expect(notification.title).to eql("Updated Title")
          expect(notification.start_date).to be_nil
        end

        it "redirects to check answers" do
          request
          expect(response).to redirect_to(notification_check_answers_path(notification))
        end
      end

      context "when show additional page is false" do
        let(:notification) { create(:notification, show_additional_page: "0", link_text: "link", page_content: "page") }
        let(:params) { { "notification": { show_additional_page: "0", link_text: "text", page_content: "content" } } }

        it "removes values for link_text and page_content" do
          request
          notification.reload
          expect(notification.link_text).to be_nil
          expect(notification.page_content).to be_nil
        end
      end
    end
  end

  context "when user is signed in as a non-support user" do
    let(:user) { create(:user, :data_coordinator) }

    before do
      sign_in user
    end

    describe "#create" do
      let(:request) { post notifications_path, params: { "notification": { title: "Test Create" } } }

      it "returns not found" do
        request
        expect(response).to have_http_status(:not_found)
      end

      it "does not create a notification" do
        expect { request }.not_to change(Notification, :count)
      end
    end

    describe "#update" do
      let(:notification) { create(:notification) }
      let(:request) { patch notification_path(notification), params: { "notification": { title: "Test Create" } } }

      it "returns not found" do
        request
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
