Feature: Password reset
  In order to sign in even if user forgot their password
  A user
  Should be able to reset it

    Scenario: User is not signed up
      Given no user exists with an email of "email@domain.local"
      When I request password reset link to be sent to "email@domain.local"
      Then I should see "The e-mail address you submitted was not found"

    Scenario: User is signed up and requests password reset
      Given I am signed up and confirmed as "email@domain.local/password"
      When I request password reset link to be sent to "email@domain.local"
      Then I should see "An email with instructions on how to access Your Account has been sent"
      And a password reset message should be sent to "email@domain.local"

    Scenario: User is signed up updated his password and types wrong confirmation
      Given I am signed up and confirmed as "email@domain.local/password"
      When I request password reset link to be sent to "email@domain.local"
      When I follow the password reset link sent to "email@domain.local"
      And I update my password with "newpassword/wrongconfirmation"
      Then I should see "Your password was not reset"
      And I should be signed out

    Scenario: User is signed up and updates his password
      Given I am signed up and confirmed as "email@domain.local/password"
      When I request password reset link to be sent to "email@domain.local"
      When I follow the password reset link sent to "email@domain.local"
      And I update my password with "newpassword/newpassword"
      Then I should be signed out
      When I go to the sign in page
      And I sign in as "email@domain.local/password"
      Then I should be signed out
      And I sign in as "email@domain.local/newpassword"
      Then I should be signed in
