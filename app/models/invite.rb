class Invite < ActiveRecord::Base
  include AASM

  # Associations
  belongs_to :user

  # Validations
  validates_associated :user, :on => :create
  validates_presence_of :recipients, :message => "can't be blank"
  validates_presence_of :subject, :message => "can't be blank"
  validates_uniqueness_of :is_default_body_for_user, :message => "must be unique", :scope => [:user_id, :type]

  # Scopes


  # Extensions
  aasm_column :state
  aasm_initial_state :draft
  aasm_state :draft
  aasm_state :active, :enter => :send_invitation
  aasm_event :activate do
    transitions :to => :active, :from => :draft
  end

  # Callbacks

  # Attributes


  private

    def send_invitation
      self.user.increment!(:invitations_count) if self.type == 'AmbassadorInvite'
      #UserMailer.deliver_ambassador_invite
    end
end
