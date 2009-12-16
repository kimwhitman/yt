# Database

Given /^A User Story has been submitted and approved from "([^\"]*)"$/ do |email|
  user_story = UserStory.create! :name => 'Sample User',
    :email => email,
    :location => 'Charlotte, NC, United States',
    :title => 'Sample Story',
    :story => 'very short',
    :is_public => true,
    :publish_at => Time.now

  UserMailer.deliver_user_story_published(user_story)
end

# Emails

Given /^a story submission approval should be sent to "([^\"]*)"$/ do |email|
  sent = ActionMailer::Base.deliveries.first

  assert_equal [email], sent.to
  assert_match /published/i, sent.subject
  assert_match /published your story/, sent.body
end
