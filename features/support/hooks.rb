Before do
  # create subscription plans
  plans = [
    { :name => 'Free',    :amount => 0,   :renewal_period => 1 },
    { :name => 'Premium', :amount => 10,  :renewal_period => 1 },
    { :name => 'Premium', :amount => 100, :renewal_period => 12 }
  ]
  plans.each { |plan| SubscriptionPlan.create(plan) }

  UserStory.create(:name => "Test Story",
  :location   => 'OMG like in America. 90210',
  :email      => 'sample@domain.com',
  :story      => 'this story is really short',
  :is_public  => true,
  :publish_at => Time.now
  )

  v = Video.create(:title => "Sample Video",
  :duration => 1.minute,
  :streaming_media_id => '123',
  :is_public => true,
  :title => 'Video Title',
  :description => 'Sample Description'
  )

  fv = FeaturedVideo.create(:video => v,
  :starts_free_at => 1.day.ago,
  :ends_free_at => 7.days.from_now)
end
