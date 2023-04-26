require "rails_helper"

RSpec.describe BulkUploadPolicy do
  subject(:policy) { described_class }

  permissions :summary?, :show? do
    it "grants access to owner" do
      user = build(:user)
      bulk_upload = build(:bulk_upload, user:)

      expect(policy).to permit(user, bulk_upload)
    end

    it "grants access to user from same org as uploader" do
      user = create(:user)
      organisation = user.organisation
      other_user = create(:user, organisation:)
      bulk_upload = create(:bulk_upload, user:)

      expect(policy).to permit(other_user, bulk_upload)
    end

    it "grants access to support" do
      user = create(:user)
      support_user = create(:user, :support)
      bulk_upload = create(:bulk_upload, user:)

      expect(policy).to permit(support_user, bulk_upload)
    end

    it "denies access to random users" do
      user = create(:user)
      other_user = create(:user)
      bulk_upload = create(:bulk_upload, user:)

      expect(policy).not_to permit(other_user, bulk_upload)
    end
  end
end
