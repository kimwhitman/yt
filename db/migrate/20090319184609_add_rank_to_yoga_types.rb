class AddRankToYogaTypes < ActiveRecord::Migration
  def self.up
    add_column :yoga_types, :rank, :integer
    
    YogaType.find(:all).each do |yt|
      yt.rank = 9
      yt.save
    end
  end

  def self.down
    remove_column :yoga_types, :rank
  end
end
