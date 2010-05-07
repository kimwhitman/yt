class ShareUrlRedirect < ActiveRecord::Base
  # Associations
  belongs_to :user
  belongs_to :share_url

  # Validations
  validates_presence_of :short_url_id, :message => "can't be blank"

  # Scopes

  # Extensions

  # Callbacks

  # Attributes
end
