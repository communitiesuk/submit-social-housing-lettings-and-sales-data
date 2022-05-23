Feature: Data Coordinator Features
  Background:
    Given I am signed in as "Data Coordinator"

  Scenario: Viewing users
    Given there are multiple users in the same organization
    When I visit the users page
    Then I see information about those users
    And the user navigation bar is highlighted

  Scenario: Viewing your organisation details
    When I visit the About your organisation page
    Then I see information about your organisation
    And the about your organisation navigation bar is highlighted
