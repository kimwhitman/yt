require 'spec_helper'

describe Video do
  describe "Published Videos" do
    after(:each) do
      Timecop.return
    end
        
    it "should be published if is_public is true and the published_date is in the past" do
      video = Video.create(:title => 'Test', :duration => 100, :description => 'This is a test', 
        :streaming_media_id => 1, :is_public => true, :published_at => Time.now)
      Timecop.freeze(Date.today + 2)
      Video.published.should include(video)
    end
    
    it "should not be published if is_public is false and the published_date is in the past" do
      video = Video.create(:title => 'Test', :duration => 100, :description => 'This is a test', 
        :streaming_media_id => 1, :is_public => false, :published_at => Time.now)
        
        Video.published.should_not include(video)
    end
    
    it "should not be published if is_public is true but the published_date is in the future" do
      video = Video.create(:title => 'Test', :duration => 100, :description => 'This is a test', 
        :streaming_media_id => 1, :is_public => true, :published_at => Time.now.advance(:months => 3))
        
      Video.published.should_not include(video)
    end
  end
end
