require "rails_helper"

RSpec.describe MergeRequest, type: :request do
  let(:user) { create(:user, :data_coordinator) }
  let(:organisation) { user.organisation }
  let(:merge_request) { create(:merge_request) }
  let(:support_user) { create(:user, :support, organisation:) }
  let(:page) { Capybara::Node::Simple.new(response.body) }

  before do
    allow(support_user).to receive(:need_two_factor_authentication?).and_return(false)
    sign_in support_user
  end

  context "when deleting a merge request" do
    it "discards the merge request" do
      delete delete_merge_request_path(merge_request)
      expect(merge_request.reload.discarded_at).not_to be_nil
    end

    it "redirects to the merge request list" do
      delete delete_merge_request_path(merge_request)
      expect(response).to redirect_to(organisations_path(tab: "merge-requests"))
      follow_redirect!
      expect(page).to have_content("Merge requests")
    end
  end
end
