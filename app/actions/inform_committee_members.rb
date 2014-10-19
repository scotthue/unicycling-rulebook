class InformCommitteeMembers

  # Send e-mail to all committee members
  # except the originator
  # and those who have opted out
  #
  def self.comment_added(comment)
    if comment.discussion.try(:proposal).try(:status) == "Submitted"
      emails = committee_admin_members_emails(comment.discussion.committee, comment.user.email)
    else
      emails = committee_members_emails(comment.discussion.committee, comment.user.email)
    end

    if emails.any?
      UserMailer.discussion_comment_added(comment, emails).deliver
    end
  end

  # Send e-mail to all committee members
  # except the originator
  # If the proposal is in "Submitted" state, only inform the committee admins, not regular users
  def self.proposal_revised(revision)
    if revision.proposal.status == "Submitted"
      emails = committee_admin_members_emails(revision.proposal.committee, revision.user.email)
    else
      emails = committee_members_emails(revision.proposal.committee, revision.user.email)
    end

    if emails.any?
      UserMailer.proposal_revised(revision, emails).deliver
    end
  end

  private

  def self.committee_members_emails(committee, exclude)
    committee.committee_members.merge(User.email_notifications).map(&:user).map(&:email) - [exclude]
  end

  def self.committee_admin_members_emails(committee, exclude)
    committee.committee_members.admin.merge(User.email_notifications).map(&:user).map(&:email) - [exclude]
  end

=begin
  def create_committee_email(proposal, committee, honor_no_email = true)
    emails = []
    CommitteeMember.all.each do |cm|
      if cm.committee == committee
        if proposal.nil? or cm.user.can? :read, proposal
          emails << cm.user.email unless (honor_no_email and cm.user.no_emails)
        end
      end
    end
    emails
  end
=end

end
