Feature: calculator

  Scenario: Entering a number
    Given a new calculator window
    When I press the "1" button
    And I press the "2" button
    And I press the "3" button
    And I press the "." button
    And I press the "4" button
    Then the result area should contain "123.4"

  Scenario: Adding two numbers
    Given a new calculator window
    When I press the "1" button
    And I press the "2" button
    And I press the "+" button
    And I press the "3" button
    And I press the "4" button
    And I press the "=" button
    Then the result area should contain "46"

  Scenario: Subtracting two numbers
    Given a new calculator window
    When I press the "8" button
    And I press the "8" button
    And I press the "-" button
    And I press the "6" button
    And I press the "6" button
    And I press the "=" button
    Then the result area should contain "22"

  Scenario: Multiplying two numbers
    Given a new calculator window
    When I press the "1" button
    And I press the "2" button
    And I press the "×" button
    And I press the "1" button
    And I press the "0" button
    And I press the "=" button
    Then the result area should contain "120"

  Scenario: Dividing two numbers
    Given a new calculator window
    When I press the "1" button
    And I press the "2" button
    And I press the "÷" button
    And I press the "3" button
    And I press the "=" button
    Then the result area should contain "4"

  Scenario: Clearing the calculator
    Given a new calculator window
    When I press the "1" button
    And I press the "2" button
    And I press the "3" button
    And I press the "4" button
    And I press the "5" button
    And I press the "6" button
    And I press the "C" button
    Then the result area should contain "0"
