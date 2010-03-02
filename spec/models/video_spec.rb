require 'spec_helper'

describe Video do
  describe "Public Videos" do
    after(:each) do
      Timecop.return
    end
        
    it "should be public if is_public is true and the published_date is in the past" do
      video = Video.create(:title => 'Test', :duration => 100, :description => 'This is a test', 
        :streaming_media_id => 1, :is_public => true, :published_at => Time.now)
        
      RAILS_DEFAULT_LOGGER.info("DEBUG #{Video.public.inspect}")
        
      Timecop.freeze(Date.today + 2)
      
      Video.public.should include(video)
    end
    
    it "should not be public if is_public is false and the published_date is in the past" do
      video = Video.create(:title => 'Test', :duration => 100, :description => 'This is a test', 
        :streaming_media_id => 1, :is_public => false, :published_at => Time.now)
        
        Video.public.should_not include(video)
    end
    
    it "should not be public if is_public is true but the published_date is in the future" do
      video = Video.create(:title => 'Test', :duration => 100, :description => 'This is a test', 
        :streaming_media_id => 1, :is_public => true, :published_at => Time.now.advance(:months => 3))
        
      Video.public.should_not include(video)
    end
  end
end
