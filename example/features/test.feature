Feature: Have Fun

  Scenario: Poking at a button
    Given the application is running
    When I press the "Press Me" button
    Then the button should no longer have the title "Press Me"

  Scenario: Setting some text
    Given the application is running
    When I input "Woot" in the textfield
    Then the textfield should have the text "Woot"
  
  
  