# General

Then /^I should see error messages$/ do
  assert_match /error(s)? prohibited/m, response.body
end

# database

Given /^no user exists with an email of "([^\"]*)"$/ do |email|
  assert_nil User.find_by_email(email)
end

Given /^I signed up with "(.*)\/(.*)"$/ do |email, password|
  user = User.create! :email => email,
    :password                => password,
    :password_confirmation   => password
end

Given /^I am signed up and confirmed as "(.*)\/(.*)"$/ do |email, password|
  user = User.new :email => email,
    :password                => password,
    :password_confirmation   => password

  user.email_confirmed = true
  user.save
  user
end

# session

Then /^I should be signed out$/ do
  assert ! controller.signed_in?
end

Then /^I should be signed in$/ do
  assert controller.signed_in?
end

When /^session is cleared$/ do
  request.reset_session
  controller.instance_variable_set(:@current_user, nil)
end

# actions

When /^I sign in( with "remember me")? as "(.*)\/(.*)"$/ do |remember, email, password|
  When %{I go to the sign in page}
  And %{I fill in "Email" with "#{email}"}
  And %{I fill in "Password" with "#{password}"}
  And %{I check "Remember me"} if remember
  And %{I press "Log In"}
end

When /^I sign out$/ do
  visit '/session', :delete
end

When /^I return next time$/ do
  When %{session is cleared}
  And %{I go to the homepage}
end

# Emails

Then /^a confirmation message should be sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  sent = ActionMailer::Base.deliveries.first
  assert_equal [user.email], sent.to
  assert_match /confirm/i, sent.subject
  assert !user.confirmation_token.blank?
  assert_match /#{user.confirmation_token}/, sent.body
end

When /^I follow the confirmation link sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  visit new_user_confirmation_path(:user_id => user, :token => user.confirmation_token)
end

