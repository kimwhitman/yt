Feature: Subscription
  In order to get access premium video content
  A user
  Should be able to upgrade their plan

  Scenario: User signs up for a premium (annual) successfully
    Given I signed up with "email@domain.local/password"
    When I sign in as "email@domain.local/password"
    Then I go to "email@domain.local"'s billing page
    When I fill in the following:
      | First Name  | Test |
      | Last Name   | User |
      | Card Number | 1    |
      | CVV, CVV2   | 112  |
    And I choose "Yoga Today 365"
    And I select "Bogus" from "Select Card Type"
    And I select "1 - January" from "creditcard_month"
    And I select "2015" from "creditcard_year"
    And I check "I agree"
    And I press "Save"
    Then I should see "Thank you for joining Yoga Today!"
    And I should see "Order total: $100.00"
    When I go to "email@domain.local"'s billing page
    Then I should see "You are signed up for the Yoga Today 365"

  Scenario: User signs up for a premium (monthly) successfully
    Given I signed up with "email@domain.local/password"
    When I sign in as "email@domain.local/password"
    Then I go to "email@domain.local"'s billing page
    When I fill in the following:
      | First Name  | Test |
      | Last Name   | User |
      | Card Number | 1    |
      | CVV, CVV2   | 112  |
    And I choose "Subscription"
    And I select "Bogus" from "Select Card Type"
    And I select "1 - January" from "creditcard_month"
    And I select "2015" from "creditcard_year"
    And I check "I agree"
    And I press "Save"
    Then I should see "Thank you for joining Yoga Today!"
    And I should see "Order total: $10.00"
    When I go to "email@domain.local"'s billing page
    Then I should see "You are signed up for monthly billing"

  Scenario: User signs up for a premium (monthly) unsuccessfully
    Given I signed up with "email@domain.local/password"
    When I sign in as "email@domain.local/password"
    Then I go to "email@domain.local"'s billing page
    When I fill in the following:
      | First Name  | Test |
      | Last Name   | User |
      | Card Number | 2    |
      | CVV, CVV2   | 112  |
    And I choose "Subscription"
    And I select "Visa" from "Select Card Type"
    And I select "1 - January" from "creditcard_month"
    And I select "2015" from "creditcard_year"
    And I check "I agree"
    And I press "Save"
    Then I should see "We were unable to obtain account authorization"

  Scenario: User signs up for a premium (annual) unsuccessfully
    Given I signed up with "email@domain.local/password"
    When I sign in as "email@domain.local/password"
    Then I go to "email@domain.local"'s billing page
    When I fill in the following:
      | First Name  | Test |
      | Last Name   | User |
      | Card Number | 2    |
      | CVV, CVV2   | 112  |
    And I choose "Yoga Today 365"
    And I select "Visa" from "Select Card Type"
    And I select "1 - January" from "creditcard_month"
    And I select "2015" from "creditcard_year"
    And I check "I agree"
    And I press "Save"
    Then I should see "We were unable to obtain account authorization"
