class AmbassadorInvite < Invite

  def deliver!
    UserMailer.deliver_ambassador_invite(self.user, self.from, self.recipients, self.subject, self.body)
    recipients_count = self.recipients.split(',').size
    recipients_count.times { self.user.increment!(:invitations_count) }
  end

end