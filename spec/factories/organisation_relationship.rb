FactoryBot.define do
  factory :organisation_relationship do
    child_organisation { FactoryBot.create(:organisation) }
    parent_organisation { FactoryBot.create(:organisation) }

    trait :owning do
      relationship_type { OrganisationRelationship::OWNING }
    end

    trait :managing do
      relationship_type { OrganisationRelationship::MANAGING }
    end
  end
end
