Feature: calculator

  Scenario: Entering a number
    Given a new calculator window
    When I press the "1" button
    And I press the "2" button
    And I press the "3" button
    Then the result area should contain "123"

  Scenario: Adding two numbers
    Given a new calculator window
    When I press the "1" button
    And I press the "2" button
    And I press the "+" button
    And I press the "3" button
    And I press the "4" button
    And I press the "=" button
    Then the result area should contain "46"
