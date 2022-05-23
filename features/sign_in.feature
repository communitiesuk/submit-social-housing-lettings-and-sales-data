Feature: Sign in

  Scenario: Signing in
    Given There is a "Data Coordinator" user in the database
    When I visit the sign in page
    And I fill in the sign in form
    And I click the sign in button
    Then I should see the logs page

  Scenario: Signing out
    Given I am signed in as "Data Coordinator"
    When I click the sign out button
    Then I should see the root page
