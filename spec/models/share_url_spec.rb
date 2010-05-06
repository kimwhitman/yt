require 'spec_helper'

describe ShareUrl do
  before(:each) do
    @valid_attributes = {
      :shareable_id => 1,
      :shareable_type => 'Invite'
    }
  end

  it "should create a new instance given valid attributes" do
    ShareUrl.create!(@valid_attributes)
  end
  
  describe "creating a token" do
    let(:share_url) { ShareUrl.create }
    
    it "should create a token" do
      share_url.token.should_not be_nil
    end
    
    it "should create a 4 character token" do
      share_url.token.size.should == 4
    end
  end
end
