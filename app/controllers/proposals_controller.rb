class ProposalsController < ApplicationController
  before_action :authenticate_user!, :except => [:show, :passed]
  before_action :load_committee, only: [:new, :create]
  skip_authorization_check only: [:create, :new]
  load_and_authorize_resource except: [:create, :new]

  # GET /proposals/passed
  # GET /proposals/passed.json
  def passed
    # the non-preliminary ones go first
    @proposals = Proposal.select{ |p| p.committee.preliminary == false and p.status == 'Passed'}
    @proposals += Proposal.select{ |p| p.committee.preliminary == true and p.status == 'Passed'}

    respond_to do |format|
      format.html # passed.html.erb
      format.json { render json: @proposals }
    end
  end

  # GET /proposals/1
  # GET /proposals/1.json
  def show
    @proposal = Proposal.find(params[:id])

    @proposal.votes.each do |v|
      if v.user == current_user
        @vote = v
      end
    end
    if can? :vote, @proposal
      if @vote.nil?
        @vote = @proposal.votes.new
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @proposal }
    end
  end

  # GET /committees/1/proposals/new
  def new
    authorize! :create_proposal, @committee
    @proposal = Proposal.new
    @revision = Revision.new
    @available_discussions = @committee.discussions.without_proposals
    @proposal_owner = current_user

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /proposals/1/edit
  def edit
    @proposal = Proposal.find(params[:id])
    @committees = current_user.accessible_committees
  end

  # POST /committees/2/proposals
  def create
    @proposal = Proposal.new(proposal_params)
    @proposal.committee = @committee
    @revision = Revision.new(revision_params)

    @discussion = Discussion.find(params[:discussion_id]) if params[:discussion_id].present?
    @proposal.discussion = @discussion
    authorize! :create_proposal, @committee

    respond_to do |format|
      if ProposalCreator.new(@proposal, @revision, @discussion, current_user).perform
        InformAdminUsers.submit_proposal(@proposal)
        format.html { redirect_to @proposal, notice: 'Proposal was successfully created.' }
        format.json { render json: @proposal, status: :created, location: @proposal }
      else
        @proposal_owner = current_user
        @available_discussions = @committee.discussions.without_proposals
        format.html { render action: "new" }
        format.json { render json: @proposal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /proposals/1
  # PUT /proposals/1.json
  def update
    @proposal = Proposal.find(params[:id])

    respond_to do |format|
      if @proposal.update_attributes(update_params)
        format.html { redirect_to @proposal, notice: 'Proposal was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @proposal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /proposals/1
  # DELETE /proposals/1.json
  def destroy
    @proposal = Proposal.find(params[:id])
    committee = @proposal.committee
    @proposal.destroy

    respond_to do |format|
      format.html { redirect_to committee_path(committee) }
      format.json { head :no_content }
    end
  end

  # PUT /proposals/1/set_voting
  def set_voting
    @proposal = Proposal.find(params[:id])

    respond_to do |format|
      if @proposal.transition_to("Voting")
        InformCommitteeMembers.proposal_call_for_voting(@proposal)
        format.html { redirect_to @proposal, notice: 'Proposal is now in the voting stage.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @proposal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /proposals/1/set_review
  def set_review
    @proposal = Proposal.find(params[:id])

    was_tabled = @proposal.status == 'Tabled'

    respond_to do |format|
      if @proposal.transition_to("Review")
        InformCommitteeMembers.proposal_status_review(@proposal, was_tabled)
        format.html { redirect_to @proposal, notice: 'Proposal is now in the review stage.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @proposal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /proposals/1/set_pre_voting
  def set_pre_voting
    @proposal = Proposal.find(params[:id])

    respond_to do |format|
      if @proposal.transition_to("Pre-Voting")
        @proposal.votes.delete_all
        format.html { redirect_to @proposal, notice: 'Proposal is now in the Pre-Voting stage. All votes have been deleted' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @proposal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /proposals/1/table
  def table
    @proposal = Proposal.find(params[:id])

    respond_to do |format|
      if @proposal.transition_to("Tabled")
        format.html { redirect_to @proposal, notice: 'Proposal has been Set-Aside' }
        format.json { head :no_content }
      else
        @proposal.status = @proposal.status_was
        flash[:alert] = "Unable to set status to Tabled unless in 'Pre-Voting' or 'Review' state"
        format.html { render action: "show" }
        format.json { render json: @proposal.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def load_committee
    @committee = Committee.find(params[:committee_id])
  end

  def proposal_params
    params.require(:proposal).permit(:title)
  end

  def update_params
    params.require(:proposal).permit(:title, :committee_id, :status, :review_start_date, :review_end_date, :vote_start_date, :vote_end_date, :tabled_date)
  end

  # XXX should be in revision-controller?
  def revision_params
    params.require(:revision).permit(:rule_text, :body, :change_description, :background, :references)
  end

end
