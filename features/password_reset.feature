Feature: Password reset
  In order to sign in even if user forgot their password
  A user
  Should be able to reset it

    Scenario: User is not signed up
      Given no user exists with an email of "email@person.com"
      When I request password reset link to be sent to "email@person.com"
      Then I should see "The e-mail address you submitted was not found"

    Scenario: User is signed up and requests password reset
      Given I am signed up and confirmed as "email@person.com/password"
      When I request password reset link to be sent to "email@person.com"
      Then I should see "An email with instructions on how to access Your Account has been sent"
      And a password reset message should be sent to "email@person.com"

    Scenario: User is signed up updated his password and types wrong confirmation
      Given I am signed up and confirmed as "email@person.com/password"
      When I request password reset link to be sent to "email@person.com"
      When I follow the password reset link sent to "email@person.com"
      And I update my password with "newpassword/wrongconfirmation"
      Then I should see "Your password was not reset"
      And I should be signed out

    Scenario: User is signed up and updates his password
      Given I am signed up and confirmed as "email@person.com/password"
      When I request password reset link to be sent to "email@person.com"
      When I follow the password reset link sent to "email@person.com"
      And I update my password with "newpassword/newpassword"
      Then I should be signed out
      When I go to the sign in page
      And I sign in as "email@person.com/password"
      Then I should be signed out
      And I sign in as "email@person.com/newpassword"
      Then I should be signed in
