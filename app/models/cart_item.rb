class CartItem < ActiveRecord::Base
  composed_of :amount, :class_name => "Money", :mapping => %w(amount amount)
  
  belongs_to :cart
  belongs_to :product, :polymorphic => true

  validates_presence_of :product_name, :amount
  validates_associated :cart, :product  
end
