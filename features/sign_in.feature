Feature: Sign in
  In order to get access to protected sections of the site
  A user
  Should be able to sign in

  Scenario: User is not signed up
    Given no user exists with an email of "email@domain.local"
    When I go to the sign in page
    And I sign in as "email@domain.local/password"
    Then I should see "Bad email or password"
    And I should be signed out

  # still deciding on how to confirm users
  @wip
  Scenario: User is not confirmed
    Given I signed up with "email@domain.local/password"
    When I go to the sign in page
    And I sign in as "email@domain.local/password"
    Then I should see "User has not confirmed email"
    And I should be signed out

  Scenario: User enters wrong password
     Given I am signed up and confirmed as "email@domain.local/password"
     When I go to the sign in page
     And I sign in as "email@domain.local/wrongpassword"
     Then I should see "Bad email or password"
     And I should be signed out

  Scenario: User signs in successfully
     Given I am signed up and confirmed as "email@domain.local/password"
     When I go to the sign in page
     And I sign in as "email@domain.local/password"
     Then I should see "My Profile"
     And I should be signed in

  Scenario: User signs in and checks "remember me"
     Given I am signed up and confirmed as "email@domain.local/password"
     When I go to the sign in page
     And I sign in with "remember me" as "email@domain.local/password"
     Then I should see "My Profile"
     And I should be signed in
     When I return next time
     Then I should be signed in
