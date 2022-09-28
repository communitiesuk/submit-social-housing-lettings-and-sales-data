class LegacyUser < ApplicationRecord
  belongs_to :user

  validates :old_user_id, uniqueness: true
end
