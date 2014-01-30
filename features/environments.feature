Feature: As a Dev
         I would like to be able to create multiple Chef environments for grouping instances

  Scenario: Create a new environment
    Given I am in the "TeamName" team
    And I am on the "TeamName" team page
    When I click "Create a new environment"
    And I select "WIP" as environment type
    And name it as "Ours"
    And I save it
    Then a new chef environment should be requested
    When I request new ec2 instance
    Then I should be able to choose "Ours(WIP)"  from list of environemnts
