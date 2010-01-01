@staging
Feature: Sign up
  In order access protected portions of the site
  As a user
  I should be able to sign up

    Scenario: User signs up with invalid data
      When I go to the sign up page
      When I fill in the following:
          | Your Name           | test user    |
          | Your Email          | invalidemail |
          | Your Email again    | invalidemail |
          | Your Password       | password     |
          | Your Password again |              |
      And I press "Sign Up"
      Then I should see error messages

    Scenario: User signs up for free account with valid data
      When I go to the sign up page
      When I fill in the following:
          | Your Name           | test user          |
          | Your Email          | email@domain.local |
          | Your Email again    | email@domain.local |
          | Your Password       | password           |
          | Your Password again | password           |
      And I choose "Free"
      And I press "Sign Up"
      Then a welcome message should be sent to "email@domain.local"
      And I should see "Your signup is complete"
      And I should be signed out

    Scenario: User signs up for a subscription with valid data
      When I go to the sign up page
      When I fill in the following:
          | Your Name           | test user          |
          | Your Email          | email@domain.local |
          | Your Email again    | email@domain.local |
          | Your Password       | password           |
          | Your Password again | password           |
      And I choose "Subscription"
      And I press "Sign Up"
      And I should be signed in
      And I should be on "email@domain.local"'s billing page
      And "Subscription" should be selected

    Scenario: User signs up for Yoga Today 365 with valid data
      When I go to the sign up page
      When I fill in the following:
          | Your Name           | test user          |
          | Your Email          | email@domain.local |
          | Your Email again    | email@domain.local |
          | Your Password       | password           |
          | Your Password again | password           |
      And I choose "Yoga Today 365"
      And I press "Sign Up"
      Then a confirmation message should not be sent to "email@domain.local"
      And I should be signed in
      And I should be on "email@domain.local"'s billing page
      And "Yoga Today 365" should be selected

    @wip
    Scenario: User confirms their free account
      Given I signed up with "email@domain.local/password"
      When I follow the confirmation link sent to "email@domain.local"
      Then I should be on "email@domain.local"'s billing page
      And I should see "Confirmed email and signed in"
      And I should be signed in
      And a welcome message should be sent to "email@domain.local"
