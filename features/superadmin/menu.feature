Feature: Menu for superadmin
  In order to access admin pages
  As a superadmin
  I want to be able to click the items in the admin menu

  Scenario: A superadmin can see the admin menu
    Given I am a superadmin
    When I am in the home page
    Then I should see the admin dropdown menu
