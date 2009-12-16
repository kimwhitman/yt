Feature: Sign out
  To protect my account from unauthorized access
  A signed in user
  Should be able to sign out

  Scenario: User signs out
    Given I am signed up and confirmed as "email@domain.local/password"
    When I sign in as "email@domain.local/password"
    Then I should be signed in
    And I sign out
    Then I should see "logged out"
    And I should be signed out

  Scenario: User who was remembered signs out
    Given I am signed up and confirmed as "email@domain.local/password"
    When I sign in with "remember me" as "email@domain.local/password"
    Then I should be signed in
    And I sign out
    Then I should see "logged out"
    And I should be signed out
    When I return next time
    Then I should be signed out
