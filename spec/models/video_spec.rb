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

  describe "Querying Brightcove API for videos" do
    it "should return an array with at least one video" do
      Brightcove::API.stub!(:get).and_return(valid_brightcove_response)
      Video.fetch_videos_from_brightcove('find_all_videos', :page_number => 1).should_not be_empty
    end

    it "should raise a Video::BrightcoveApiError exception when brightcove returns an error" do
      Brightcove::API.stub!(:get).and_return(error_brightcove_response)
      lambda { Video.fetch_videos_from_brightcove('find_all_videos')}.should raise_error(Video::BrightcoveApiError)
    end
  end

  describe "Importing Videos from Brightcove" do
    before(:each) do
      Instructor.make(:name => "Sarah Kline")
      YogaType.make(:name => "Hatha Blend")
      VideoFocus.make(:name => "Twists")
      SkillLevel.make(:name => "Yogis")
    end

    it "should create a brand new video with a good response from Brightcove" do
      Video.stub!(:full_version?).and_return(true)
      brightcove_response = [Hashie::Mash.new(valid_brightcove_response).items.first]
      Video.stub!(:fetch_videos_from_brightcove).and_return(brightcove_response)
      Video.import_videos_from_brightcove

      Video.count.should == 1
    end

    it "should not create a brand new video with a good response from Brightcove when a video already exists with that friendly name" do
      video = Video.make_unsaved(:friendly_name => 'S075', :title => 'Test Title')
      video.instructors << Instructor.make
      video.yoga_types << YogaType.make

      video.save

      Video.stub!(:full_version?).and_return(true)
      brightcove_response = [Hashie::Mash.new(valid_brightcove_response).items.first]
      Video.stub!(:fetch_videos_from_brightcove).and_return(brightcove_response)
      Video.import_videos_from_brightcove

      Video.count.should == 1
    end

    it "should be published when it's set to public and the published date is in the past" do
      brightcove_response = [Hashie::Mash.new(valid_brightcove_response).items.first]
      brightcove_response.first.publishedDate = (2.weeks.ago.to_i * 1000).to_s
      brightcove_response.first.customFields.public = 'True'

      video = Video.make_unsaved(:friendly_name => 'S075', :title => 'Test Title')
      video.instructors << Instructor.make(:name => 'Robby Russell')
      video.yoga_types << YogaType.make
      video.save

      Video.stub!(:full_version?).and_return(true)
      Video.stub!(:fetch_videos_from_brightcove).and_return(brightcove_response)
      Video.import_videos_from_brightcove

      Video.published.should include(video)
    end

    it "should not be published when it's set to public and the published date is in the future" do
      brightcove_response = [Hashie::Mash.new(valid_brightcove_response).items.first]
      brightcove_response.first.publishedDate = (3.weeks.from_now.to_i * 1000).to_s
      brightcove_response.first.customFields.public = 'True'

      video = Video.make_unsaved(:friendly_name => 'S075', :title => 'Test Title')
      video.instructors << Instructor.make(:name => 'Robby Russell')
      video.yoga_types << YogaType.make
      video.save

      Video.stub!(:full_version?).and_return(true)
      Video.stub!(:fetch_videos_from_brightcove).and_return(brightcove_response)
      Video.import_videos_from_brightcove

      Video.published.should_not include(video)
    end

    it "should change an existing video's published at timestamp" do
      two_weeks_ago = (2.weeks.ago.to_i * 1000).to_s
      brightcove_response = [Hashie::Mash.new(valid_brightcove_response).items.first]
      brightcove_response.first.publishedDate = two_weeks_ago
      brightcove_response.first.customFields.public = 'True'

      video = Video.make_unsaved(:friendly_name => 'S075', :title => 'Test Title', :published_at => Time.zone.now )
      video.instructors << Instructor.make(:name => 'Robby Russell')
      video.yoga_types << YogaType.make
      video.save

      Video.stub!(:full_version?).and_return(true)
      Video.stub!(:fetch_videos_from_brightcove).and_return(brightcove_response)
      Video.import_videos_from_brightcove

      video.reload
      video.published_at.should == (Time.at(two_weeks_ago.to_i / 1000))
    end

    it "should not be published when it's not public" do
      brightcove_response = [Hashie::Mash.new(valid_brightcove_response).items.first]
      brightcove_response.first.publishedDate = (2.weeks.ago.to_i * 1000).to_s
      brightcove_response.first.customFields.public = 'False'

      video = Video.make_unsaved(:friendly_name => 'S075', :title => 'Test Title')
      video.instructors << Instructor.make(:name => 'Robby Russell')
      video.yoga_types << YogaType.make
      video.save

      Video.stub!(:full_version?).and_return(true)
      Video.stub!(:fetch_videos_from_brightcove).and_return(brightcove_response)
      Video.import_videos_from_brightcove

      video.reload

      Video.published.should_not include(video)
    end

    it "should import a video when it's not public" do
      brightcove_response = [Hashie::Mash.new(valid_brightcove_response).items.first]
      brightcove_response.first.publishedDate = (2.weeks.ago.to_i * 1000).to_s
      brightcove_response.first.customFields.public = 'False'

      video = Video.make_unsaved(:friendly_name => 'S075', :title => 'Test Title')
      video.instructors << Instructor.make(:name => 'Robby Russell')
      video.yoga_types << YogaType.make
      video.save

      Video.stub!(:full_version?).and_return(true)
      Video.stub!(:fetch_videos_from_brightcove).and_return(brightcove_response)
      Video.import_videos_from_brightcove

      video.reload

      Video.count.should == 1
    end

    it "should not import a video if it's a preview video" do
      Video.stub!(:full_version?).and_return(false)
      brightcove_response = [Hashie::Mash.new(valid_brightcove_response).items.first]
      Video.stub!(:fetch_videos_from_brightcove).and_return(brightcove_response)
      Video.import_videos_from_brightcove

      Video.count.should == 0
    end
    
    it "should send an email when there is a problem importing a video" do
      brightcove_response = [Hashie::Mash.new(valid_brightcove_response).items.first]
      brightcove_response.first.publishedDate = (2.weeks.ago.to_i * 1000).to_s
      brightcove_response.first.customFields.public = 'False'
      brightcove_response.first.longDescription = nil
      
      Video.stub!(:fetch_videos_from_brightcove).and_return(brightcove_response)
      ErrorMailer.stub!(:deliver_video_import_failure)
      ErrorMailer.should_receive(:deliver_video_import_failure)
      Video.import_videos_from_brightcove
    end
    
    it "should send an email when there is an exception during the import process" do
      Brightcove::API.stub!(:get).and_return(error_brightcove_response)
      
      ErrorMailer.stub!(:deliver_error)
      ErrorMailer.should_receive(:deliver_error)
      Video.import_videos_from_brightcove
    end
  end
end