class Form < ApplicationRecord
  self.abstract_class = true

  FIRST_QUESTION_FOR_SUBSECTION = {
    "Household characteristics" => "form/questions/tenant_code",
    "Household situation" => "form/questions/previous_housing_situation"
  }.freeze

  QUESTIONS = {
    "tenant_code" => "form/questions/tenant_age",
    "tenant_age" => "form/questions/tenant_gender",
    "tenant_gender" => "form/questions/tenant_ethnic_group",
    "tenant_ethnic_group" => "form/questions/tenant_nationality",
  }.freeze
end
