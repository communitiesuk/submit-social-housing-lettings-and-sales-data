require "rails_helper"
require_relative "form/helpers"

RSpec.describe "Notifications Features" do
  include Helpers

  context "when there are notifications" do
    let!(:user) { FactoryBot.create(:user) }

    context "when the notifications are currently active" do
      before do
        create(:notification, start_date: Time.zone.yesterday, title: "Notification title 1")
        create(:notification, start_date: Time.zone.yesterday, end_date: Time.zone.tomorrow, title: "Notification title 2")
        sign_in user
        visit(root_path)
      end

      it "shows the notification banner" do
        expect(page).to have_content("Notification 1 of")
        expect(page).to have_link("Dismiss")
      end
    end

    context "when the notifications are not currently active" do
      before do
        create(:notification, start_date: Time.zone.yesterday, end_date: Time.zone.yesterday, title: "Notification title 1")
        create(:notification, start_date: Time.zone.tomorrow, title: "Notification title 2")
        create(:notification, start_date: nil, title: "Notification title 3")
        sign_in user
        visit(root_path)
      end

      it "does not show the notifications banner" do
        expect(page).not_to have_content("Notification 1 of")
        expect(page).not_to have_link("Dismiss")
      end
    end
  end
end
