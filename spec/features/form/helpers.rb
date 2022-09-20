module Helpers
  def fill_in_number_question(lettings_log_id, question, value, path)
    visit("/logs/#{lettings_log_id}/#{path}")
    fill_in("lettings-log-#{question.to_s.dasherize}-field", with: value)
    click_button("Save and continue")
  end

  def answer_all_questions_in_income_subsection(lettings_log)
    visit("/logs/#{lettings_log.id}/net-income")
    fill_in("lettings-log-earnings-field", with: 18_000)
    choose("lettings-log-incfreq-2-field")
    click_button("Save and continue")
    choose("lettings-log-benefits-0-field")
    click_button("Save and continue")
    choose("lettings-log-hb-1-field")
    click_button("Save and continue")
  end

  def sign_in(user)
    visit("/logs")
    fill_in("user[email]", with: user.email)
    fill_in("user[password]", with: user.password)
    click_button("Sign in")
  end
end
