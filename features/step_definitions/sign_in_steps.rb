Given('There is a user in the database') do
  @user = create :user
end

When('I visit the sign in page') do
  visit("/account/sign-in")
end

When('I fill in the sign in form') do
  fill_in("user[email]", with: @user.email)
  fill_in("user[password]", with: @user.password)
end

When('I click the sign in button') do
  click_button("Sign in")
end

Then('I should see the logs page') do
  expect(page).to have_current_path("/logs")
end
