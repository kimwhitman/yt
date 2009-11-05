class AddRankToYogaPoses < ActiveRecord::Migration
  def self.up
    add_column :yoga_poses, :rank, :integer
    
    YogaPose.find(:all).each do |yp|
      yp.rank = 9
      yp.save
    end
  end

  def self.down
    remove_column :yoga_poses, :rank
  end
end
