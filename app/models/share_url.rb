class ShareUrl < ActiveRecord::Base
  BASE_URL = 'http://yogaurl.com/'
  
  include TokenGenerator::Simple
  
  # Associations
  belongs_to :user
  has_many :share_url_redirects

  # Validations
  validates_associated :user, :if => Proc.new { |share_url| !share_url.token.blank? }
  validates_uniqueness_of :token, :scope => [:user_id]

  # Scopes

  # Extensions

  # Callbacks
  before_validation_on_create :set_token
  before_save :format_path

  # Attributes
  
  def track_redirect(params)
    self.share_url_redirects.create!(params)
  end
  
  protected
    def set_token
      if self.token.blank?
        self.token = generate_token(4)
      else
        self.token = self.token.downcase
      end
    end    
end
