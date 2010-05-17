class BillingTransaction < ActiveRecord::Base
  # Associations
  belongs_to :billing, :polymorphic => true

  # Validations
  validates_presence_of :billing_id, :billing_type, :amount
  validates_presence_of :authorization_code, :message => "can't be blank", :unless => Proc.new { |bi| bi.amount == 0 }

  # Scopes

  # Extensions

  # Callbacks

  # Attributes

end
