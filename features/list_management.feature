Feature: Lists Management
  In order to participate in the Intralist community
  As a user
  I need to be able to create and manage lists
  
  Scenario: View all lists
    Given I have lists named Top 5 Country Singers, Top NYC Restaurants
    When I am on the lists page
    Then I should see "Top 5 Country Singers"
    And I should see "Top NYC Restaurants"
  
  Scenario: Don't show private list on lists page
    Given I have a private list named Top Camino Moments and public lists named Top 5 Tech Gadgets, Top 5 NFL Teams
    When I am on the lists page
    Then I should see "Top 5 Tech Gadgets"
    And I should see "Top 5 NFL Teams"
    Then I should not see "Top Camino Moments"
  
  Scenario: Show private lists on My Lists page
    Given I have a private list named Top Camino Moments
    When I am on the My Lists page
    Then I should see "Top 5 Camino Moments"
  
  Scenario: Create a list
  
  Scenario: Add items to list
  
  Scenario: Edit a list
  
  Scenario: Change list privacy
  
  Scenario: Show related lists when viewing a list
  
  Scenario: Show other lists by user when viewing a user's list
  

  