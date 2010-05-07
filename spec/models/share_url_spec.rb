require 'spec_helper'

describe ShareUrl do
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    ShareUrl.create!(@valid_attributes)
  end
  
  describe "creating a token" do
    let(:share_url) { ShareUrl.new }
    
    it "should create a token when a token isn't already set" do
      share_url.save
      share_url.token.should_not be_nil
    end
    
    it "should not generate a token when it's already set" do
      share_url.token = 'test'
      share_url.save
      share_url.token.should == 'test'
    end
    
    it "should create a 4 character token if a token isn't already set" do
      share_url.save
      share_url.token.size.should == 4
    end
  end
end
