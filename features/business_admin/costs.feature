Feature: As a manager
         To keep company effective
         I need to know cost of each instance

  Background:
    Given I am a business_admin

  @javascript
  Scenario: Teams costs
    Given I have a "Alpha" team
    And "Alpha" team has an instance which costs 40 dollars for "November 2013"
    And "Alpha" team has an instance which costs 50 dollars for "December 2013"
    And the "Beta" team
    And "Beta" team has an instance which costs 30 dollars for "November 2013"
    And the "Beta" team is inactive
    And costs for AWS in "December 2013" is 700 dollars
    When I proceed to "Billing" page
    Then I see that "Alpha" team costs 50 dollars
    And I see that total cost are 700 dollars
    And I should not see "Beta"

    When I select "November 2013" as date
    Then I see that "Alpha" team costs 40 dollars
    And I see that "Beta (inactive)" team costs 30 dollars
    And I see that total Pantry costs are 70 dollars
