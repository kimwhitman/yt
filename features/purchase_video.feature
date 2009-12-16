Feature: Purchase Video
  In order to watch videos
  A user
  Should be able to purchase videos for offline viewing

Scenario: purchase a single video
  Given the following videos:
    |title|duration|is_public|friendly_name|description|streaming_media_id|
    |Yoga for Runners|3600|true|A001|Yoga for runners description|123|
  When I go to the home page
  And I follow "Show all Classes"
  Then I add "Yoga for Runners" to the cart
  When I go to the shopping cart pages
  Then I should see "Cart (1)"
  And I go to the checkout page
  Then I should see "1 item"
  And I fill in "purchase[first_name]" with "Anonymous"
  And I fill in "purchase[last_name]" with "User"
  And I fill in "purchase[email]" with "email@person.com"
  And I select "A Totally Bogus Card." from "purchase[card_type]"
  And I fill in "purchase[card_number]" with "4111111111111111"
  And I fill in "purchase[card_verification]" with "112"
  And I select "January" from "purchase[card_expiration(2i)]"
  And I select "2019" from "purchase[card_expiration(1i)]"
  And I press "Purchase"
  Then I should see "Thank you for your purchase"
  And a receipt should be emailed to "email@person.com"

Scenario: purchase a single video with a bad credit card
  Given the following videos:
    |title|duration|is_public|friendly_name|description|streaming_media_id|
    |Yoga for Runners|3600|true|A001|Yoga for runners description|123|
  When I go to the home page
  And I follow "Show all Classes"
  Then I add "Yoga for Runners" to the cart
  When I go to the shopping cart page
  Then I should see "Cart (1)"
  And I go to the checkout page
  Then I should see "1 item"
  And I fill in "purchase[first_name]" with "Anonymous"
  And I fill in "purchase[last_name]" with "User"
  And I fill in "purchase[email]" with "email@person.com"
  And I select "Discover" from "purchase[card_type]"
  And I fill in "purchase[card_number]" with "4111"
  And I fill in "purchase[card_verification]" with "112"
  And I select "January" from "purchase[card_expiration(2i)]"
  And I select "2019" from "purchase[card_expiration(1i)]"
  And I press "Purchase"
  Then I should see "unable to obtain account authorization"
