Given('there are multiple users in the same organization') do
  @users = create_list :user, 5, organisation: @user.organisation
end

Given('I visit the users page') do
  click_link("Users")
end

Then('I see information about those users') do
  @users.each do |user|
    expect(page.body).to have_content user.name
    expect(page.body).to have_content user.email
  end
end
