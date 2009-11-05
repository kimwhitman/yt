namespace :user_stories do
  desc "Announces to a user (by email) that their Yoga Today user story has been posted."
  task :announce_published => :environment do
    # Find all published stories that haven't announced via email their publish status.
    UserStory.published.find(:all, :conditions => { :has_announced_publish => false }).each do |user_story|
      puts "Announcing publish of '#{user_story.title}' (ID: #{user_story.id}) to #{user_story.name} (#{user_story.email})"
      UserMailer.deliver_user_story_published(user_story)
    end    
  end
  
  desc "Loads the initial list of 638 stories"
  task :load_initials => :environment do
    require 'fastercsv'
    FasterCSV.foreach("#{RAILS_ROOT}/public/stories/initial_data.csv") do |row|
      row0 = row[0].nil? ? "" : row[0]
      row1 = row[1].nil? ? "" : row[1]
      row2 = row[2].nil? ? "" : row[2]
      row3 = row[3].nil? ? "" : row[3]
      row4 = row[4].nil? ? "" : row[4]
      row5 = row[5].nil? ? "" : row[5]
      row6 = row[6].nil? ? "" : row[6]
      row7 = row[7].nil? ? "" : row[7]
      row8 = row[8].nil? ? "" : row[8]
      row9 = row[9].nil? ? "" : row[9]
      name = ([row0] + [row1]).delete_if{|x| x.empty?}.join(" ")
      location = ([row2] + [row3] + [row4]).delete_if{|x| x.empty?}.join(", ")
      email = row5
      publish_at = row6
      title = row7
      story = row8
      us = UserStory.new(:name => name, :location => location, :email => email, :publish_at => publish_at, :title => title, :story => story, :is_public => true)
      unless row9.blank?
      	image = "#{RAILS_ROOT}/public/stories/#{row9}"
      	us.image = File.open(image, "r")
  	  end
      us.save
    end
  end
  
end
