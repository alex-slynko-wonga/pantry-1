Feature: As a manager
  To keep company effective
  I need to know cost of each instance

Scenario: Teams costs
    Given I am a manager
    And the "Alpha" team
    And it has an instance which costs 100 dollars for 2 months
    And it has an instance which costs 50 dollars for 1 month
    And the "Beta" team
    When I proceed to "Billing" page
    Then I see that "Alpha" team costs 150 dollars
    And I see that "Beta" team costs 0 dollars

    When I open details for "Alpha" team costs
    Then I see 100 and 50 as instances cost

    When I click "Previous month"
    Then I see that "Alpha" team costs 50 dollars

