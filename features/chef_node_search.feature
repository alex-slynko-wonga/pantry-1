Feature: Search Chef Nodes
  In order to access Node information on Chef
  As DevOps
  I want to see list of Chef Nodes search results after searching by environment and role

  @chef-zero
  Scenario: Chef Node search
    Given the node "awinpaintwwwl01.test.example.com" with environment "awinpaint"
    When I search for node with environment "awinpaint"
    Then I should see "node[awinpaintwwwl01.test.example.com]"
