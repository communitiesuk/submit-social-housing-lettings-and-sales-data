When("I visit the sign in page") do
  visit "/account/sign-in"
end

When("I fill in the sign in form") do
  fill_in("user[email]", with: @user.email)
  fill_in("user[password]", with: @user.password)
end

When("I click the sign in button") do
  click_button("Sign in")
end

Then("I should see the logs page") do
  expect(page).to have_current_path("/logs")
end

Then("I should see the root page") do
end

Given("There is a {string} user in the database") do |role|
  @user = create :user, role: role.parameterize(separator: "_")
end

Given("I am signed in as {string}") do |role|
  step "There is a \"#{role}\" user in the database"
  step "I visit the sign in page"
  step "I fill in the sign in form"
  step "I click the sign in button"
end

When("I click the sign out button") do
  click_link("Sign out")
end
