Feature: As a manager
  To keep company effective
  I need to know cost of each instance

  @javascript
  Scenario: Teams costs
    Given I am a manager
    And I have a "Alpha" team
    And "Alpha" team has an instance which costs 40 dollars for "November" "2013"
    And "Alpha" team has an instance which costs 50 dollars for "December" "2013"
    And I have a "Beta" team
    And "Beta" team has an instance which costs 30 dollars for "November" "2013"
    When I proceed to "Billing" page
    Then I see that "Alpha" team costs 50 dollars
    And I see that "Beta" team costs 0 dollars
    
    When I select "November 2013" as date
    Then I see that "Alpha" team costs 40 dollars
    And I see that "Beta" team costs 30 dollars
