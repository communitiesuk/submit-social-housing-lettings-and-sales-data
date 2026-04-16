# Used to allow for easier auditing of what users downloaded what info
# Caches some info about the user at the time of download
class DownloadRecord < ApplicationRecord
  belongs_to :user
  belongs_to :user_organisation, class_name: "Organisation"

  DOWNLOAD_TYPE = {
    user: 0,
    lettings_log: 1,
    sales_log: 2,
    organisation: 3,
    scheme: 4,
  }.freeze

  enum download_type: DOWNLOAD_TYPE
  enum user_role: User::ROLES

  def self.build_from_user(user:, **attrs)
    new(
      user:,
      user_organisation: user.organisation,
      user_role: user.role,
      **attrs,
    )
  end
end
