module SoftValidations
  def soft_errors
    @soft_errors = {}
    net_income_validations
    @soft_errors
  end

  private

  def net_income_validations
    if weekly_net_income && person_1_economic_status && override_net_income_validation.blank?
      if weekly_net_income < applicable_income_range.soft_min && weekly_net_income > applicable_income_range.hard_min
        @soft_errors["weekly_net_income"] = OpenStruct.new(
          message: "Net income is lower than expected based on the main tenant's working situation. Are you sure this is correct?",
          hint_text: "This is based on the tenant's work situation: #{person_1_economic_status}"
        )
      elsif weekly_net_income > applicable_income_range.soft_max && weekly_net_income < applicable_income_range.hard_max
        @soft_errors["weekly_net_income"] = OpenStruct.new(
          message: "Net income is higher than expected based on the main tenant's working situation. Are you sure this is correct?",
          hint_text: "This is based on the tenant's work situation: #{person_1_economic_status}"
        )
      end
    elsif weekly_net_income && person_1_economic_status && override_net_income_validation.present?
      if weekly_net_income > applicable_income_range.soft_min && weekly_net_income < applicable_income_range.soft_max
        self.update(override_net_income_validation: nil)
      end
    end
  end
end
