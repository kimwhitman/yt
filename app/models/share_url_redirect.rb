class ShareUrlRedirect < ActiveRecord::Base
  # Associations
  belongs_to :person
  belongs_to :short_url

  # Validations
  validates_presence_of :short_url_id, :message => "can't be blank"

  # Scopes

  # Extensions

  # Callbacks

  # Attributes
end
