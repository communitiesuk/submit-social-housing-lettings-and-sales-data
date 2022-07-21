module SchemesHelpers
  def fill_in_number_question(case_log_id, question, value, path)
    visit("/logs/#{case_log_id}/#{path}")
    fill_in("case-log-#{question.to_s.dasherize}-field", with: value)
    click_button("Save and continue")
  end

  def answer_all_questions_in_income_subsection(case_log)
    visit("/logs/#{case_log.id}/net-income")
    fill_in("case-log-earnings-field", with: 18_000)
    choose("case-log-incfreq-2-field")
    click_button("Save and continue")
    choose("case-log-benefits-0-field")
    click_button("Save and continue")
    choose("case-log-hb-1-field")
    click_button("Save and continue")
  end

  def sign_in(user)
    visit("/logs")
    fill_in("user[email]", with: user.email)
    fill_in("user[password]", with: user.password)
    click_button("Sign in")
  end

  def fill_in_and_save_scheme_details(answers = {})
    fill_in "Scheme name", with: "FooBar"
    check "This scheme contains confidential information"
    choose "Direct access hostel"
    choose "Yes – registered care home providing nursing care"
    select organisation.name, from: "scheme-owning-organisation-id-field"
    choose answers["housing_stock_owners"].presence || "The same organisation that owns the housing stock"
    click_button "Save and continue"
  end

  def fill_in_and_save_primary_client_group
    choose "Homeless families with support needs"
    click_button "Save and continue"
  end

  def fill_in_and_save_secondary_client_group_confirmation
    choose "Yes"
    click_button "Save and continue"
  end

  def fill_in_and_save_secondary_client_group
    choose "Homeless families with support needs"
    click_button "Save and continue"
  end

  def fill_in_and_save_support
    choose "Low level"
    choose "Very short stay"
    click_button "Save and continue"
  end

  def fill_in_and_save_location
    fill_in "Postcode", with: "SW1P 4DF"
    fill_in "Location name (optional)", with: "Some name"
    fill_in "Total number of units at this location", with: 1
    choose "Self-contained house"
    choose "location-add-another-location-no-field"
    choose "location-mobility-type-none-field"
    click_button "Save and continue"
  end

  def fill_in_and_save_second_location
    fill_in "Postcode", with: "XX1 1XX"
    fill_in "Location name (optional)", with: "Other name"
    fill_in "Total number of units at this location", with: 2
    choose "Self-contained house"
    choose "location-add-another-location-no-field"
    choose "location-mobility-type-none-field"
    click_button "Save and continue"
  end

  def create_and_save_a_scheme
    fill_in_and_save_scheme_details
    fill_in_and_save_primary_client_group
    fill_in_and_save_secondary_client_group_confirmation
    fill_in_and_save_secondary_client_group
    fill_in_and_save_support
  end
end
