# Database

Given /^A User Story has been submitted and approved from "([^\"]*)"$/ do |email|
  UserStory.create! :name => 'Sample User',
    :email => email,
    :location => 'Charlotte, NC, United States',
    :title => 'Sample Story',
    :story => 'very short',
    :is_public => true,
    :publish_at => Time.now
end

# Emails

Then /^a story submission message should be sent to "([^\"]*)"$/ do |email|
  sent = ActionMailer::Base.deliveries.first

  assert_equal [email], sent.to
  assert_match /submitted/i, sent.subject
  assert_match /tell us your story/, sent.body
end

Given /^a story submission approval should be sent to "([^\"]*)"$/ do |arg1|
  sent = ActionMailer::Base.deliveries.first

  assert_equal [email], sent.to
  assert_match /published/i, sent.subject
  assert_match /has been published/, sent.body
end
