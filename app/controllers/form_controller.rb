class FormController < ApplicationController

  FIRST_QUESTION_FOR_SUBSECTION = {
    "Household characteristics" => "case_logs/household/tenant_code",
  }

  NEXT_QUESTION = {
    "tenant_code" => "case_logs/household/tenant_age",
    "tenant_age" => "case_logs/household/tenant_gender",
    "tenant_gender" => "case_logs/household/tenant_ethnic_group",
    "tenant_ethnic_group" => "case_logs/household/tenant_nationality"
  }


  def next_question
    subsection = params[:subsection]
    result = if subsection
      FIRST_QUESTION_FOR_SUBSECTION[subsection]
    else
      NEXT_QUESTION[params[:previous_question]]
    end
    render result
  end
end
