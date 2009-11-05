class AddRankToVideoFocus < ActiveRecord::Migration
  def self.up
    add_column :video_focus, :rank, :integer
    
    VideoFocus.find(:all).each do |vf|
      vf.rank = 9
      vf.save
    end
  end

  def self.down
    remove_column :video_focus, :rank
  end
end
