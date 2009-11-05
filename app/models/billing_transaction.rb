class BillingTransaction < ActiveRecord::Base
  belongs_to :billing, :polymorphic => true
  validates_presence_of :billing_id, :billing_type, :amount, :authorization_code
end
