namespace :core do
  # TODO: Remove once ran on all environments.
  desc "Creates a LegacyUser object for any existing Users"
  task sync_legacy_users: :environment do
    User.where.not(old_user_id: nil).includes(:legacy_users).find_each do |user|
      next if user.legacy_users.where(old_user_id: user.old_user_id).any?

      user.legacy_users.create!(old_user_id: user.old_user_id)
    end
  end
end
