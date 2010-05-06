class ShareUrl < ActiveRecord::Base
  BASE_URL = 'http://yogaurl.com/'
  
  include TokenGenerator::Simple
  
  # Associations
  belongs_to :shareable, :polymorphic => :true

  # Validations
  validates_presence_of :shareable_id
  validates_presence_of :shareable_type
  validates_uniqueness_of :token, :scope => [:shareable_id, :shareable_type]

  # Scopes

  # Extensions

  # Callbacks
  before_validation_on_create :set_token

  # Attributes
  
  def url
    "#{BASE_URL}#{self.token}"
  end
  
  protected
    def set_token
      self.token = generate_token(4)
    end
end
