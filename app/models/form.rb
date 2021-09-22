class Form < ApplicationRecord
  self.abstract_class = true

  SECTIONS = {
    "About the household" => %w[household_characteristics household_situation household_needs],
    "Tenancy and property information" => %w[tenancy_information property_information],
    "Rent and charges" => %w[income_and_benefits rent],
    "Local Authority" => %w[local_authority],
    "Submission" => %w[declaration],
  }.freeze

  SUBSECTIONS = {
    "household_characteristics" => "tenant_code",
    "household_situation" => "previous_housing_situation",
    "household_needs" => "tenant_code",
    "tenancy_information" => "tenant_code",
    "property_information" => "tenant_code",
    "income_and_benefits" => "tenant_code",
    "rent" => "tenant_code",
    "local_authority" => "tenant_code",
    "declaration" => "tenant_code",
  }.freeze

  QUESTIONS = {
    "tenant_code" => "tenant_age",
    "tenant_age" => "tenant_gender",
    "tenant_gender" => "tenant_ethnic_group",
    "tenant_ethnic_group" => "tenant_nationality",
    "tenant_nationality" => "tenant_economic_status",
    "tenant_economic_status" => "household_number_of_other_members",
    "household_number_of_other_members" => "household_number_of_other_members",
    "previous_housing_situation" => "previous_housing_situation",
  }.freeze

  def self.first_question_for_subsection(subsection)
    SUBSECTIONS[subsection]
  end

  def self.next_question(previous_question)
    Form::QUESTIONS[previous_question]
  end

  def self.previous_question(current_question)
    Hash[QUESTIONS.to_a.map(&:reverse)][current_question]
  end
end
