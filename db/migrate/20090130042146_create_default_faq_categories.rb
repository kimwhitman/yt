class CreateDefaultFaqCategories < ActiveRecord::Migration
  def self.up
    FaqCategory.create :name => 'Yoga Questions'
    FaqCategory.create :name => 'Billing Questions'
    FaqCategory.create :name => 'Technical Questions'
  end

  def self.down
    
  end
end
