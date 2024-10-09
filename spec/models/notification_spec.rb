require "rails_helper"

RSpec.describe Notification, type: :model do
  describe "#valid?" do
    context "when show additional page is true" do
      context "and page_content is blank" do
        let(:notification) { build(:notification, show_additional_page: true, page_content: "") }

        it "adds an error to page_content" do
          notification.valid?

          expect(notification.errors[:page_content]).to include("Enter the page content.")
        end
      end

      context "and link_text is blank" do
        let(:notification) { build(:notification, show_additional_page: true, link_text: nil) }

        it "adds an error to link_text" do
          notification.valid?

          expect(notification.errors[:link_text]).to include("Enter the link text.")
        end
      end
    end

    context "when show additional page is false" do
      context "and page_content and link_text are blank" do
        let(:notification) { build(:notification, show_additional_page: false, link_text: nil, page_content: nil) }

        it "is valid" do
          expect(notification).to be_valid
        end
      end
    end
  end
end
