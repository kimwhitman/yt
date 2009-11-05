class ContactEmail
  attr_reader :first_name, :last_name, :email, :message
  def initialize(params = {})
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @email = params[:email]
    @message = params[:message]
  end
  def full_name
    "#{first_name} #{last_name}"
  end
  def valid?
    [first_name, last_name, email, message].all? { |attr| !attr.blank? }
  end
end