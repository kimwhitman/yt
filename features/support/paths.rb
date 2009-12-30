module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'
    when /the new sign_in page/
      new_sign_in_path
    when /the sign in page/
      login_path
    when /the sign up page/
      sign_up_path
    when /the forgot password page/
      forgot_password_path
    when /^"(.*)"'s profile page$/i
      profile_user_path(User.find_by_email($1))
    when /^"(.*)"'s billing page$/i
      billing_user_path(User.find_by_email($1))
    when /the shopping cart page/
      cart_path
    when /the checkout page/
      checkout_path
    when /user stories page/
      user_stories_path


    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
