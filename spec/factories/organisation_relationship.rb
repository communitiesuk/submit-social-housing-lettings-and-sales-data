FactoryBot.define do
  factory :organisation_relationship do
    child_organisation { FactoryBot.create(:organisation) }
    parent_organisation { FactoryBot.create(:organisation) }
  end
end
