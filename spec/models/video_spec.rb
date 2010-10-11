require 'spec_helper'
require 'helpers/video_spec_helper'

describe Video do
  before(:each) do
    Video.stub!(:remote_properties)
    @instructors = Instructor.make
    @yoga_types = YogaType.make
  end
  
  describe "Published Videos" do
    after(:each) do
      Timecop.return
    end

    it "should be published if is_public is true and the published_date is in the past" do
      video = Video.make_unsaved(:published_at => Time.zone.now)
      video.instructors << @instructors
      video.yoga_types << @yoga_types
      video.save
      Timecop.freeze(Date.today + 2)
      
      Video.published.should include(video)
    end

    it "should not be published if is_public is false and the published_date is in the past" do
      video = Video.make_unsaved(:is_public => false, :published_at => Time.zone.now)
      video.instructors << @instructors
      video.yoga_types << @yoga_types
      video.save
      
      Video.published.should_not include(video)
    end

    it "should not be published if is_public is true but the published_date is in the future" do
      video = Video.make_unsaved(:published_at => Time.zone.now.advance(:months => 3))
      video.instructors << @instructors
      video.yoga_types << @yoga_types
      video.save
      
      Video.published.should_not include(video)
    end
  end

  describe "This weeks videos" do
    before(:each) do
      @today = Date.parse('2010-03-03') # Wednesday, March 3rd, 2010
      Timecop.freeze(@today)

      @video_1 = Video.make_unsaved(:published_at => Date.parse('2010-03-01'))
      @video_2 = Video.make_unsaved(:published_at => Date.parse('2010-03-06'))
      @old_video = Video.make_unsaved(:published_at => Date.parse('2010-02-20'))
      @future_video = Video.make_unsaved(:published_at => Date.parse('2010-03-20'))
      
      [@video_1, @video_2, @old_video, @future_video].each do |video|
        video.instructors << @instructors
        video.yoga_types << @yoga_types
        video.save
      end
    end

    after(:each) do
      Timecop.return
    end

    it "should return videos that are/will be published this week" do
      Video.this_week.should include(@video_1, @video_2)
    end

    it "should not return videos that are not scheduled in the future" do
      Video.this_week.should_not include(@future_video)
    end

    it "should not return videos that were published before this week" do
      Video.this_week.should_not include(@old_video)
    end

    it "should not return videos that are scheduled after this week" do
      Video.this_week.should_not include(@future_video)
    end
  end

  describe "Upcoming Videos" do
    it "should return videos that will be published in the future" do
      Timecop.freeze(Date.today + 2)
      (1..2).each do |interval|
        self.instance_variable_set("@video_#{interval}", Video.make_unsaved(:published_at => Time.zone.now))
      end
      
      [@video_1, @video_2].each do |video|
        video.instructors << @instructors
        video.yoga_types << @yoga_types
        video.save
      end
      
      Timecop.return

      @video_3 = Video.make_unsaved(:published_at => Time.zone.now)
      @video_3.instructors << @instructors
      @video_3.yoga_types << @yoga_types
      @video_3.save

      Video.upcoming.should include(@video_1, @video_2)
    end

    it "should not return videos that are published in the past" do
      Timecop.freeze(Date.today + 2)
      (1..2).each do |interval|
        self.instance_variable_set("@video_#{interval}", Video.make_unsaved(:published_at => Time.zone.now))
      end
      
      [@video_1, @video_2].each do |video|
        video.instructors << @instructors
        video.yoga_types << @yoga_types
        video.save
      end

      Timecop.return

      @video_3 = Video.make_unsaved(:published_at => Time.zone.now)
        
      @video_3.instructors << @instructors
      @video_3.yoga_types << @yoga_types
      @video_3.save        

      Video.upcoming.should_not include(@video_3)
    end
  end
  
  describe "Converting Brightcove Reference ID" do
    it "should insert two zeros after the first character and remove any suffixes when the prefix is 2 characters in size" do
      reference_id = 'A7-HD'
      
      Video.convert_brightcove_reference_id(reference_id).should == 'A007'
    end
    
    it "should insert a zero after the first character and remove any suffixes when the prefix is 3 characters in size" do
      reference_id = 'A07-HD'
      
      Video.convert_brightcove_reference_id(reference_id).should == 'A007'
    end
    
    it "should not insert zeros but should remove suffixes when the prefix is more than 3 characters in size" do
      reference_id = 'A0007-HD'
      
      Video.convert_brightcove_reference_id(reference_id).should == 'A0007'
    end
  end
end