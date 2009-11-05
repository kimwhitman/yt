class AddDefaultSkillLevels < ActiveRecord::Migration
  def self.up
    SkillLevel.transaction do
      # SkillLevel.new(foobar).save!
      SkillLevel.new(:name => "First Time", :description => " New to Yoga? If you're just starting out give these classes a try until you feel comfortable moving on up to Novice.").save!
      SkillLevel.new(:name => "Novice", :description => " Please try Novice level classes if you have only practiced a few times.").save!
      SkillLevel.new(:name => "Yogis", :description => " These classes are for intermediate-advanced level yogis. We'll move through sequences a little faster and try postures that take some experience.").save!
      SkillLevel.new(:name => "Guru", :description => " These classes are for intermediate-advanced level yogis. We'll move through sequences a little faster and try postures that take some experience.").save!
    end
  end

  def self.down
    SkillLevel.delete_all
  end
end
