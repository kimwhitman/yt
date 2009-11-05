class AddRankToGetStartedTodays < ActiveRecord::Migration
  def self.up
    add_column :get_started_todays, :rank, :integer
    
    GetStartedToday.find(:all).each do |gst|
      gst.rank = 9
      gst.save
    end
  end

  def self.down
    remove_column :get_started_todays, :rank
  end
end
