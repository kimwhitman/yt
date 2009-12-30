@staging
Feature: Unsubscribe
  In order an account from being billed
  As a user
  I should be able to cancel their subscription

  Scenario: Paying user unsubscribes
    Given I signed up as an "Annual" member for "email@domain.local/password"
    When I sign in as "email@domain.local/password"
    And I am on "email@domain.local"'s billing page
    And I follow "Cancel Membership"
    And I check "accept_cancel_terms"
    And I press "Cancel Membership"
    Then I should see "Your subscription has been canceled"
    And I should see "Reactivate Membership"
    And a cancellation message should be sent to "email@domain.local"

  Scenario: Free users should not be able to unsubscribe
    Given I signed up as a "Free" member for "email@domain.local/password"
    When I sign in as "email@domain.local/password"
    And I am on "email@domain.local"'s billing page
    Then I should not see "Cancel Membership"
