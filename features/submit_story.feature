Feature: Story submission
  In order to allow users to have a voice on the website
  As a user
  I should be able to submit their stories for approval

Scenario: Non-account holder submits story
  Given I am on the user stories page
  And I follow "Submit Your Story"
  And I fill in "first_name" with "Test"
  And I fill in "last_name" with "User"
  And I fill in "city" with "Charlotte"
  And I select "NC" from "state"
  And I fill in "user_story[email]" with "test@domain.local"
  And I fill in "user_story[title]" with "More awesome story"
  And I fill in "user_story[story]" with "is very short"
  And I press "Tell Us Your Story"
  Then I should see "Thanks for submitting your story"

Scenario: A submitted story gets approved
  Given A User Story has been submitted and approved from "test@domain.local"
  Then a story submission approval should be sent to "test@domain.local"
