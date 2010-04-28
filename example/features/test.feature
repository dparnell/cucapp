Feature: Have Fun

  Scenario: Poking at a button
    Given the application is running
    When I press the "Press Me" button
    Then the button should no longer have the title "Press Me"

