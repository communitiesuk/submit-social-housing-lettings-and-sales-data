Feature: Sign in

  @wip
  Scenario: Signing in
    Given There is a user in the database
    When I visit the sign in page
    And I fill in the sign in form
    And I click the sign in button
    Then I should see the logs page
