class Form::Sales::Subsections::HouseholdCharacteristics < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "household_characteristics"
    @label = "Household characteristics"
  end

  def depends_on
    if form.start_year_2025_or_later?
      [{ "setup_completed?" => true }]
    else
      [{ "setup_completed?" => true, "company_buyer?" => false }]
    end
  end

  def pages
    @pages ||= [
      (Form::Sales::Pages::BuyerInterview.new("buyer_interview_joint_purchase", nil, self, joint_purchase: true) unless form.start_year_2024_or_later?),
      (Form::Sales::Pages::BuyerInterview.new("buyer_interview", nil, self, joint_purchase: false) unless form.start_year_2024_or_later?),
      (Form::Sales::Pages::PrivacyNotice.new("privacy_notice_joint_purchase", nil, self, joint_purchase: true) unless form.start_year_2024_or_later?),
      (Form::Sales::Pages::PrivacyNotice.new("privacy_notice", nil, self, joint_purchase: false) unless form.start_year_2024_or_later?),
      Form::Sales::Pages::Age1.new(nil, nil, self),
      Form::Sales::Pages::RetirementValueCheck.new("age_1_retirement_value_check", nil, self, person_index: 1),
      (Form::Sales::Pages::NotRetiredValueCheck.new("age_1_not_retired_value_check", nil, self, person_index: 1) if form.start_year_2024_or_later?),
      Form::Sales::Pages::OldPersonsSharedOwnershipValueCheck.new("age_1_old_persons_shared_ownership_joint_purchase_value_check", nil, self, joint_purchase: true),
      Form::Sales::Pages::OldPersonsSharedOwnershipValueCheck.new("age_1_old_persons_shared_ownership_value_check", nil, self, joint_purchase: false),
      (Form::Sales::Pages::SexRegisteredAtBirth1.new(nil, nil, self) if form.start_year_2026_or_later?),
      (Form::Sales::Pages::GenderIdentity1.new(nil, nil, self) unless form.start_year_2026_or_later?),
      Form::Sales::Pages::Buyer1EthnicGroup.new(nil, nil, self),
      Form::Sales::Pages::Buyer1EthnicBackgroundBlack.new(nil, nil, self),
      Form::Sales::Pages::Buyer1EthnicBackgroundAsian.new(nil, nil, self),
      Form::Sales::Pages::Buyer1EthnicBackgroundArab.new(nil, nil, self),
      Form::Sales::Pages::Buyer1EthnicBackgroundMixed.new(nil, nil, self),
      Form::Sales::Pages::Buyer1EthnicBackgroundWhite.new(nil, nil, self),
      Form::Sales::Pages::Buyer1Nationality.new(nil, nil, self),
      Form::Sales::Pages::Buyer1WorkingSituation.new(nil, nil, self),
      Form::Sales::Pages::RetirementValueCheck.new("working_situation_1_retirement_value_check", nil, self, person_index: 1),
      (Form::Sales::Pages::NotRetiredValueCheck.new("working_situation_1_not_retired_value_check", nil, self, person_index: 1) if form.start_year_2024_or_later?),
      Form::Sales::Pages::Buyer1IncomeEcstatValueCheck.new("working_situation_buyer_1_income_value_check", nil, self),
      Form::Sales::Pages::Buyer1LiveInProperty.new(nil, nil, self),
      Form::Sales::Pages::BuyerLiveInValueCheck.new("buyer_1_live_in_property_value_check", nil, self, person_index: 1),
      (form.start_year_2025_or_later? ? Form::Sales::Pages::Buyer2RelationshipToBuyer1YesNo.new(nil, nil, self) : Form::Sales::Pages::Buyer2RelationshipToBuyer1.new(nil, nil, self)),
      (Form::Sales::Pages::PersonStudentNotChildValueCheck.new("buyer_2_relationship_student_not_child_value_check", nil, self, person_index: 2) unless form.start_year_2025_or_later?),
      Form::Sales::Pages::Age2.new(nil, nil, self),
      Form::Sales::Pages::OldPersonsSharedOwnershipValueCheck.new("age_2_old_persons_shared_ownership_joint_purchase_value_check", nil, self, joint_purchase: true),
      Form::Sales::Pages::OldPersonsSharedOwnershipValueCheck.new("age_2_old_persons_shared_ownership_value_check", nil, self, joint_purchase: false),
      Form::Sales::Pages::RetirementValueCheck.new("age_2_buyer_retirement_value_check", nil, self, person_index: 2),
      (Form::Sales::Pages::NotRetiredValueCheck.new("age_2_buyer_not_retired_value_check", nil, self, person_index: 2) if form.start_year_2024_or_later?),
      (Form::Sales::Pages::PersonStudentNotChildValueCheck.new("buyer_2_age_student_not_child_value_check", nil, self, person_index: 2) unless form.start_year_2025_or_later?),
      (Form::Sales::Pages::SexRegisteredAtBirth2.new(nil, nil, self) if form.start_year_2026_or_later?),
      (Form::Sales::Pages::GenderIdentity2.new(nil, nil, self) unless form.start_year_2026_or_later?),
      buyer_2_ethnicity_nationality_pages,
      Form::Sales::Pages::Buyer2WorkingSituation.new(nil, nil, self),
      Form::Sales::Pages::RetirementValueCheck.new("working_situation_2_retirement_value_check_joint_purchase", nil, self, person_index: 2),
      (Form::Sales::Pages::NotRetiredValueCheck.new("working_situation_2_not_retired_value_check_joint_purchase", nil, self, person_index: 2) if form.start_year_2024_or_later?),
      Form::Sales::Pages::Buyer2IncomeEcstatValueCheck.new("working_situation_buyer_2_income_value_check", nil, self),
      (Form::Sales::Pages::PersonStudentNotChildValueCheck.new("buyer_2_working_situation_student_not_child_value_check", nil, self, person_index: 2) unless form.start_year_2025_or_later?),
      Form::Sales::Pages::Buyer2LiveInProperty.new(nil, nil, self),
      Form::Sales::Pages::BuyerLiveInValueCheck.new("buyer_2_live_in_property_value_check", nil, self, person_index: 2),
      Form::Sales::Pages::NumberOfOthersInProperty.new("number_of_others_in_property", nil, self, joint_purchase: false),
      Form::Sales::Pages::NumberOfOthersInProperty.new("number_of_others_in_property_joint_purchase", nil, self, joint_purchase: true),
      (2..6).flat_map { |index| person_pages(index) },
    ].flatten.compact
  end

  def person_pages(person_index)
    [
      Form::Sales::Pages::PersonKnown.new("person_#{person_index}_known", nil, self, person_index:),
      (form.start_year_2025_or_later? ? Form::Sales::Pages::PersonRelationshipToBuyer1YesNo.new("person_#{person_index}_relationship_to_buyer_1", nil, self, person_index:) : Form::Sales::Pages::PersonRelationshipToBuyer1.new("person_#{person_index}_relationship_to_buyer_1", nil, self, person_index:)),
      (Form::Sales::Pages::PartnerUnder16ValueCheck.new("relationship_#{person_index}_partner_under_16_value_check", nil, self, person_index:) if form.start_year_2024_or_later?),
      (Form::Sales::Pages::MultiplePartnersValueCheck.new("relationship_#{person_index}_multiple_partners_value_check", nil, self, person_index:) if form.start_year_2024_or_later?),
      (Form::Sales::Pages::PersonStudentNotChildValueCheck.new("relationship_#{person_index}_student_not_child_value_check", nil, self, person_index:) unless form.start_year_2025_or_later?),
      Form::Sales::Pages::PersonAge.new("person_#{person_index}_age", nil, self, person_index:),
      Form::Sales::Pages::RetirementValueCheck.new("age_#{person_index}_retirement_value_check", nil, self, person_index:),
      (Form::Sales::Pages::NotRetiredValueCheck.new("age_#{person_index}_not_retired_value_check", nil, self, person_index:) if form.start_year_2024_or_later?),
      (Form::Sales::Pages::PersonStudentNotChildValueCheck.new("age_#{person_index}_student_not_child_value_check", nil, self, person_index:) unless form.start_year_2025_or_later?),
      (Form::Sales::Pages::PartnerUnder16ValueCheck.new("age_#{person_index}_partner_under_16_value_check", nil, self, person_index:) if form.start_year_2024_or_later?),
      (Form::Sales::Pages::PersonGenderIdentity.new("person_#{person_index}_gender_identity", nil, self, person_index:) unless form.start_year_2026_or_later?),
      (Form::Sales::Pages::PersonSexRegisteredAtBirth.new("person_#{person_index}_sex_registered_at_birth", nil, self, person_index:) if form.start_year_2026_or_later?),
      Form::Sales::Pages::PersonWorkingSituation.new("person_#{person_index}_working_situation", nil, self, person_index:),
      Form::Sales::Pages::RetirementValueCheck.new("working_situation_#{person_index}_retirement_value_check", nil, self, person_index:),
      (Form::Sales::Pages::NotRetiredValueCheck.new("working_situation_#{person_index}_not_retired_value_check", nil, self, person_index:) if form.start_year_2024_or_later?),
      (Form::Sales::Pages::PersonStudentNotChildValueCheck.new("working_situation_#{person_index}_student_not_child_value_check", nil, self, person_index:) unless form.start_year_2025_or_later?),
    ]
  end

  def buyer_2_ethnicity_nationality_pages
    if form.start_date.year >= 2023
      [
        Form::Sales::Pages::Buyer2EthnicGroup.new(nil, nil, self),
        Form::Sales::Pages::Buyer2EthnicBackgroundBlack.new(nil, nil, self),
        Form::Sales::Pages::Buyer2EthnicBackgroundAsian.new(nil, nil, self),
        Form::Sales::Pages::Buyer2EthnicBackgroundArab.new(nil, nil, self),
        Form::Sales::Pages::Buyer2EthnicBackgroundMixed.new(nil, nil, self),
        Form::Sales::Pages::Buyer2EthnicBackgroundWhite.new(nil, nil, self),
        Form::Sales::Pages::Buyer2Nationality.new(nil, nil, self),
      ]
    end
  end

  def displayed_in_tasklist?(log)
    return true if form.start_year_2025_or_later?

    !log.company_buyer?
  end
end
