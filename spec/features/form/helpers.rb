module Helpers
  def fill_in_number_question(case_log_id, question, value, path)
    visit("/case_logs/#{case_log_id}/#{path}")
    fill_in("case-log-#{question.to_s.dasherize}-field", with: value)
    click_button("Save and continue")
  end

  def answer_all_questions_in_income_subsection(case_log)
    visit("/case_logs/#{case_log.id}/net_income")
    fill_in("case-log-earnings-field", with: 18_000)
    choose("case-log-incfreq-yearly-field")
    click_button("Save and continue")
    choose("case-log-benefits-all-field")
    click_button("Save and continue")
    choose("case-log-hb-prefer-not-to-say-field")
    click_button("Save and continue")
  end

  def sign_in(user)
    visit("/case_logs")
    fill_in("user_email", with: user.email)
    fill_in("user_password", with: user.password)
    click_button("Sign in")
  end
end
