class Invite < ActiveRecord::Base
  include AASM

  # Associations
  belongs_to :user
  has_many :share_urls, :as => :shareable, :dependent => :destroy

  # Validations
  validates_associated :user, :on => :create
  validates_presence_of :recipients, :message => "can't be blank"
  validates_presence_of :subject, :message => "can't be blank"
  #validates_uniqueness_of :is_default_body_for_user, :message => "must be unique", :scope => [:user_id, :type]

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
  after_validation_on_create :set_default_body_for_user
  after_validation_on_update :set_default_body_for_user

  # Attributes


  private

    def set_default_body_for_user
      if self.is_default_body_for_user?
        previous_invite_with_default_body = self.user.invites.find(:first,
          :conditions => ['id <> ? AND is_default_body_for_user = ? AND type = ?', self.id, true, self.class.to_s])
        previous_invite_with_default_body.update_attributes(:is_default_body_for_user => false) if previous_invite_with_default_body
      end
    end

    def send_invitation
      # TODO Call mailer...

      self.user.increment!(:invitations_count) if self.type == 'AmbassadorInvite'
    end
end
