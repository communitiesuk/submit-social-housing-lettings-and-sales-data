Feature: Data Coordinator Features
  Background:
    Given I am signed in as "Data Coordinator"

  Scenario: Viewing users
    Given there are multiple users in the same organization
    When I visit the users page
    Then I see information about those users
    And the user navigation bar is highlighted
  
  Scenario: Viewing your organisation details
    When I visit the about your organisation page
    Then I see information about your organisation
    And the about your organisation navigation bar is highlighted

  Scenario: Viewing your account
    When I visit the your account page
    Then I see information about my account
    And the no links in navigation bar are highlighted

  @wip
  Scenario: Changing your password
    When I visit the your account page
    And I click to change my password
    And I fill in new password and confirmation
    And I click to update my password
    Then my password should be updated
