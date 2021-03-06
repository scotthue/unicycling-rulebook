class InformAdminUsers

  # send an e-mail to all Admin users
  def self.new_applicant(user)
    if admin_emails.any?
      UserMailer.delay.new_committee_applicant(user.id, admin_emails)
    end
  end

  # send an -email to all admins,
  # and also set the mail_message_id for the proposal
  # so that future e-mails are all threaded similarly
  def self.submit_proposal(proposal)
    if admin_emails.any?
      UserMailer.delay.proposal_submitted(proposal.id, admin_emails)
    end
  end


  private

  def self.admin_emails
    User.admin.email_notifications.map(&:email)
  end
end
