namespace :db do
  desc 'Load an initial set of data'
  task :bootstrap => :environment do
    Rake::Task["db:schema:load"].invoke
    plans = [
      { 'name' => 'Free', 'amount' => 0, 'user_limit' => 2 },
      { 'name' => 'Basic', 'amount' => 10, 'user_limit' => 5 },
      { 'name' => 'Premium', 'amount' => 30, 'user_limit' => nil }
    ].collect do |plan|
      SubscriptionPlan.create(plan)
    end
    user = User.new(:name => 'Test', :login => 'test', :password => 'test', :password_confirmation => 'test', :email => 'test@example.com')
    a = Account.create(:name => 'Test Account', :domain => 'localhost', :plan => plans.first, :user => user)
    a.update_attribute(:full_domain, 'localhost')

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
    :ends_free_at => 1.year.from_now)
  end
end