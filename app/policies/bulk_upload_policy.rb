class BulkUploadPolicy
  attr_reader :user, :bulk_upload

  def initialize(user, bulk_upload)
    @user = user
    @bulk_upload = bulk_upload
  end

  def summary?
    owner? || same_org? || user.support?
  end

  def show?
    owner? || same_org? || user.support?
  end

private

  def owner?
    bulk_upload.user == user
  end

  def same_org?
    bulk_upload.user.organisation.users.include?(user)
  end
end
