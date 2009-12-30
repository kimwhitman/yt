Feature: Change subscription
  In order allow users to change their subscription
  As a user
  I should be able to upgrade or downgrade my plan at any time

  Scenario: Upgrade from free to monthly
    Given I signed up as a "Free" member for "email@domain.local/password"
    When I sign in as "email@domain.local/password"
    And I go to "email@domain.local"'s profile page
    And I follow "Subscribe to Yoga Today"
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
    Then I should see "Welcome to Yoga Today"
    And I should see "Order total: $10.00"
    When I go to "email@domain.local"'s profile page
    And I follow "Payment info"
    Then I should see "You are signed up for monthly billing"

  Scenario: Upgrade from free to annual
    Given I signed up as a "Free" member for "email@domain.local/password"
    When I sign in as "email@domain.local/password"
    And I go to "email@domain.local"'s profile page
    And I follow "Subscribe to Yoga Today"
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
    Then I should see "Welcome to Yoga Today"
    And I should see "Order total: $100.00"
    When I go to "email@domain.local"'s profile page
    And I follow "Payment info"
    Then I should see "You are signed up for the Yoga Today 365"
    And I should see "Billing will occur annually"

    Scenario: Upgrade to monthly to annual
      Given I signed up as an "Monthly" member for "email@domain.local/password"
      When I sign in as "email@domain.local/password"
      And I go to "email@domain.local"'s profile page
      And I follow "Payment Info"
      When I fill in the following:
        | First Name  | Test |
        | Last Name   | User |
        | Card Number | 1    |
        | CVV, CVV2   | 112  |
      And I choose "Yoga Today 365"
      And I select "Bogus" from "Select Card Type"
      And I select "1 - January" from "creditcard_month"
      And I select "2015" from "creditcard_year"
      And I press "Save"
      Then I should see "You are signed up for the Yoga Today 365"
      And I should see "Billing will occur annually"

    Scenario: Downgrade from annual to monthly
      Given I signed up as an "Annual" member for "email@domain.local/password"
      When I sign in as "email@domain.local/password"
      And I go to "email@domain.local"'s profile page
      And I follow "Payment Info"
      When I fill in the following:
        | First Name  | Test |
        | Last Name   | User |
        | Card Number | 1    |
        | CVV, CVV2   | 112  |
      And I choose "Subscription"
      And I select "Bogus" from "Select Card Type"
      And I select "1 - January" from "creditcard_month"
      And I select "2015" from "creditcard_year"
      And I press "Save"
      Then I should see "You are signed up for monthly billing"

    Scenario: Downgrade from annual to free
      Given I signed up as an "Annual" member for "email@domain.local/password"
      When I sign in as "email@domain.local/password"
      And I go to "email@domain.local"'s profile page
      And I follow "Payment Info"
      And I choose "Free"
      And I press "Save"
      Then I should see "If you wish to cancel your membership, please click 'Cancel Membership'"

    Scenario: Downgrade from annual to free
      Given I signed up as an "Annual" member for "email@domain.local/password"
      When I sign in as "email@domain.local/password"
      And I go to "email@domain.local"'s profile page
      And I follow "Payment Info"
      And I choose "Free"
      And I press "Save"
      Then I should see "If you wish to cancel your membership, please click 'Cancel Membership'"
