class BillingTransaction < ActiveRecord::Base
  # Associations
  belongs_to :billing, :polymorphic => true

  # Validations
  validates_presence_of :billing_id, :billing_type, :amount, :authorization_code

  # Scopes

  # Extensions

  # Callbacks

  # Attributes

end
