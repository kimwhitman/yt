# email

Then /^a cancellation message should be sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)

  sent = ActionMailer::Base.deliveries.first

  assert_equal [user.email], sent.to
  assert_match /cancelled/i, sent.subject
  assert_match /reactivate/i, sent.body
end
