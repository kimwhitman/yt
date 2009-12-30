# General

# avoid external api calls
ConstantContact.stubs(:subscribe).returns(nil)
ConstantContact.stubs(:unsubscribe).returns(nil)
RestClient.stubs(:get).returns("{ }")

Then /^I should see error messages$/ do
  assert_match /(error(s)? prohibited)|(errorExplanation)/m, response.body
end

Then /^"([^\"]*)" should be selected$/ do |field|
  assert field_labeled(field).checked?
end

# Database

Given /^no user exists with an email of "([^\"]*)"$/ do |email|
  assert_nil User.find_by_email(email)
end

Given /^I signed up with "(.*)\/(.*)"$/ do |email, password|
  user = User.create! :email => email,
    :password                => password,
    :password_confirmation   => password,
    :name => 'Test User'
end

Given /^I signed up as an? "([^\"]*)" member for "(.*)\/(.*)"$/ do |plan_name, email, password|
  user = User.create! :email => email,
    :password                => password,
    :password_confirmation   => password,
    :name => 'Test User'

  cc = ActiveMerchant::Billing::CreditCard.new(:type => 'bogus',
        :number => '1',
        :month => Date.today.month,
        :year => Date.today.year + 5,
        :first_name => "First Name",
        :last_name => "Last Name"
        )

  case plan_name
  when /free/i
  when /monthly/i
    user.account.subscription.upgrade_to_premium(1)
    user.account.subscription.store_card(cc)
  when /annual/i
    user.account.subscription.upgrade_to_premium(12)
    user.account.subscription.store_card(cc)
  end
end



Given /^I am signed up and confirmed as "(.*)\/(.*)"$/ do |email, password|
  user = User.new :email => email,
    :password                => password,
    :password_confirmation   => password,
    :name => 'Test User'

  user.email_confirmed = true
  user.save
  user
end

# Session

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

# Actions

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

When /^I request password reset link to be sent to "(.*)"$/ do |email|
  When %{I go to the forgot password page}
  And %{I fill in "E-mail" with "#{email}"}
  And %{I press "Submit"}
end

When /^I update my password with "(.*)\/(.*)"$/ do |password, confirmation|
  And %{I fill in "Password" with "#{password}"}
  And %{I fill in "Password Confirmation" with "#{confirmation}"}
  And %{I press "Change password"}
end

When /^I follow the confirmation link sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  visit new_user_confirmation_path(:user_id => user, :token => user.confirmation_token)
end

When /^I follow the password reset link sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  reset = PasswordReset.find_by_user_id(user.id)
  assert reset
  token = reset.token
  visit reset_password_path(:token => token)
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

Then /^a confirmation message should not be sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  sent = ActionMailer::Base.deliveries.first

  if sent
    assert_not_equal [user.email], sent.to
  end
end

Then /^a welcome message should be sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)

  sent = ActionMailer::Base.deliveries.first
  assert_equal [user.email], sent.to
  assert_match /welcome/i, sent.subject
  assert_match /welcome/i, sent.body
end

Then /^a password reset confirmation should be sent to "([^\"]*)"$/ do |email|
  user = User.find_by_email(email)

  sent = ActionMailer::Base.deliveries.last

  assert_equal [user.email], sent.to
  assert_match /password reset confirmation/i, sent.subject
  assert_match /successfully reset/, sent.body
end

Then /^a password reset message should be sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  pr = PasswordReset.find_by_user_id(user.id)

  sent = ActionMailer::Base.deliveries.first

  assert_equal [user.email], sent.to
  assert_match /password reset/i, sent.subject
  assert !pr.token.blank?
  assert_match /#{pr.token}/, sent.body
end
