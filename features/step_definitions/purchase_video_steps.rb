Given /^the following videos:$/ do |videos|
  videos.hashes.each do |hash|
    Video.create!(hash)
  end

  FeaturedVideo.create(:rank => 1,
    :starts_free_at => Time.now,
    :ends_free_at => 7.days.since,
    :video_id => Video.last.id)
end

Then /^I add "([^\"]*)" to the cart$/ do |video_title|
  Then %{I should see "#{video_title}"}

  video = Video.find_by_title(video_title)

  # simulate the ajax request
  visit("/shopping_cart/add/#{video.id}", :put)
end

# Emails
Then /^a receipt should be emailed to "(.*)"$/ do |email|
  sent = ActionMailer::Base.deliveries.first
  assert_equal [email], sent.to
  assert_match /recent purchase/i, sent.subject
  assert_match /download instructions/i, sent.body
end
