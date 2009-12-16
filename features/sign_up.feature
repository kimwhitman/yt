Feature: Sign up
  In order to get access to protected sections of the site
  A user
  Should be able to sign up

    Scenario: User signs up with invalid data
      When I go to the sign up page
      And I fill in "Your name" with "test user"
      And I fill in "Your Email" with "invalidemail"
      And I fill in "Your Password" with "password"
      And I fill in "Your Password Again" with ""
      And I press "Sign Up"
      Then I should see error messages

    Scenario: User signs up for free account with valid data
      When I go to the sign up page
      And I choose "Free"
      And I fill in "Your name" with "test user"
      And I fill in "Your Email" with "email@person.com"
      And I fill in "Your Email Again" with "email@person.com"
      And I fill in "Your Password" with "password"
      And I fill in "Your Password Again" with "password"
      And I press "Sign Up"
      Then I should see "Instructions have been emailed to you"
      And I should be signed out
      And a confirmation message should be sent to "email@person.com"

    Scenario: User signs up for a monthly account with valid data
      When I go to the sign up page
      And I choose "Subscription"
      And I fill in "Your name" with "test user"
      And I fill in "Your Email" with "email@person.com"
      And I fill in "Your Email Again" with "email@person.com"
      And I fill in "Your Password" with "password"
      And I fill in "Your Password Again" with "password"
      And I press "Sign Up"
      And a confirmation message should be sent to "email@person.com"

    Scenario: User signs up for a prepaid account with valid data
      When I go to the sign up page
      And I choose "Prepaid"
      And I fill in "Your name" with "test user"
      And I fill in "Your Email" with "email@person.com"
      And I fill in "Your Email Again" with "email@person.com"
      And I fill in "Your Password" with "password"
      And I fill in "Your Password Again" with "password"
      And I press "Sign Up"
      And a confirmation message should be sent to "email@person.com"

    Scenario: User confirms his account
      Given I signed up with "email@person.com/password"
      When I follow the confirmation link sent to "email@person.com"
      Then I should be on "email@person.com"'s billing page
      And I should see "Confirmed email and signed in"
      And I should be signed in
      And a welcome message should be sent to "email@person.com"

