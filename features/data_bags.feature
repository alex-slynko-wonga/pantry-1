Feature: Data Bags
  In order to see current status
  As DevOps
  I want to see list of data bags

  Scenario: Data Bags list
    Given the data bag "Test Bag" is stored on "https://chef.example.com"
    When I am on data bags page
    Then I should see "Test Bag"

