require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe VotesController, :type => :controller do
  before(:each) do
    @proposal = FactoryGirl.create(:proposal, :with_admin, :status => 'Voting')
    @admin_user = FactoryGirl.create(:admin_user)
    @user = FactoryGirl.create(:user)
    FactoryGirl.create(:committee_member, :committee => @proposal.committee, :voting => true, :user => @user)

    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # Vote. As you add validations to Vote, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { vote: 'agree',
      comment: ''
    }
  end

  describe "GET index" do
    before(:each) do
        sign_out @user
        sign_in @admin_user
    end
    it "assigns all votes as @votes" do
      vote = FactoryGirl.create(:vote, :proposal => @proposal)
      get :index, {:proposal_id => @proposal.id}
      expect(assigns(:votes)).to eq([vote])
    end
    it "should only show votes from this proposal" do
      vote = FactoryGirl.create(:vote, :proposal => @proposal)
      other_vote = FactoryGirl.create(:vote)
      get :index, {:proposal_id => @proposal.id}
      expect(assigns(:votes)).to eq([vote])
    end
  end

  describe "GET new" do
    it "assigns a new vote as @vote" do
      get :new, {:proposal_id => @proposal.id}
      expect(assigns(:vote)).to be_a_new(Vote)
    end
  end

  describe "GET edit" do
    describe "as normal user" do
      it "cannot view the edit page" do
        vote = FactoryGirl.create(:vote, :proposal => @proposal)
        get :edit, {:id => vote.to_param, :proposal_id => @proposal.id}
        expect(response).to redirect_to(root_path)
      end
    end

    describe "as admin" do
      before(:each) do
        sign_out @user
        sign_in @admin_user
      end
      it "assigns the requested vote as @vote" do
        vote = FactoryGirl.create(:vote, :proposal => @proposal)
        get :edit, {:id => vote.to_param, :proposal_id => @proposal.id}
        expect(assigns(:vote)).to eq(vote)
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Vote" do
        expect {
          post :create, {:vote => valid_attributes, :proposal_id => @proposal.id}
        }.to change(Vote, :count).by(1)
      end

      it "assigns a newly created vote as @vote" do
        post :create, {:vote => valid_attributes, :proposal_id => @proposal.id}
        expect(assigns(:vote)).to be_a(Vote)
        expect(assigns(:vote)).to be_persisted
      end

      it "redirects to the created vote" do
        post :create, {:vote => valid_attributes, :proposal_id => @proposal.id}
        expect(response).to redirect_to(@proposal)
      end
      it "sends an email" do
        ActionMailer::Base.deliveries.clear
        post :create, {:vote => valid_attributes, :proposal_id => @proposal.id}
        num_deliveries = ActionMailer::Base.deliveries.size
        expect(num_deliveries).to eq(1)
      end
    end
    describe "when the proposal is not in voting" do
        before(:each) do
            @proposal.status = 'Submitted'
            @proposal.save!
        end
        it "should not be possible to create a vote" do
          expect {
            post :create, {:vote => valid_attributes, :proposal_id => @proposal.id}
          }.to change(Vote, :count).by(0)
        end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved vote as @vote" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Vote).to receive(:save).and_return(false)
        post :create, {:vote => {vote: 'agree'}, :proposal_id => @proposal.id}
        expect(assigns(:vote)).to be_a_new(Vote)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Vote).to receive(:save).and_return(false)
        post :create, {:vote => {vote: 'agree'}, :proposal_id => @proposal.id}
        expect(response).to render_template("proposals/show")
      end
    end
  end

  describe "PUT update" do
    before(:each) do
        @vote = FactoryGirl.create(:vote, :proposal => @proposal)
    end
    describe "as a normal user" do
      it "redirects to the vote" do
        put :update, {:id => @vote.to_param, :vote => valid_attributes, :proposal_id => @proposal.id}
        expect(response).to redirect_to(root_path)
      end
    end

    describe "with admin with valid params" do
      before(:each) do
        sign_out @user
        sign_in @admin_user
      end
      it "updates the requested vote" do
        # Assuming there are no other votes in the database, this
        # specifies that the Vote created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Vote).to receive(:update_attributes).with({})
        put :update, {:id => @vote.to_param, :vote => {'these' => 'params'}, :proposal_id => @proposal.id}
      end

      it "assigns the requested vote as @vote" do
        put :update, {:id => @vote.to_param, :vote => valid_attributes, :proposal_id => @proposal.id}
        expect(assigns(:vote)).to eq(@vote)
      end

      it "redirects to the vote" do
        put :update, {:id => @vote.to_param, :vote => valid_attributes, :proposal_id => @proposal.id}
        expect(response).to redirect_to([@proposal, @vote])
      end
      it "sends an e-mail" do
        ActionMailer::Base.deliveries.clear
        put :update, {:id => @vote.to_param, :vote => {vote: 'disagree'}, :proposal_id => @proposal.id}
        num_deliveries = ActionMailer::Base.deliveries.size
        expect(num_deliveries).to eq(1)

        note = ActionMailer::Base.deliveries.first
        expect(note.body).to match(' agree to disagree')
      end
    end

    describe "with admin and invalid params" do
      before(:each) do
        sign_out @user
        sign_in @admin_user
      end
      it "assigns the vote as @vote" do
        vote = FactoryGirl.create(:vote, :proposal => @proposal)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Vote).to receive(:save).and_return(false)
        put :update, {:id => vote.to_param, :vote => {vote: 'agree'}, :proposal_id => @proposal.id}
        expect(assigns(:vote)).to eq(vote)
      end

      it "re-renders the 'edit' template" do
        vote = FactoryGirl.create(:vote, :proposal => @proposal)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Vote).to receive(:save).and_return(false)
        put :update, {:id => vote.to_param, :vote => {vote: 'agree'}, :proposal_id => @proposal.id}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "should not be allowed" do
      vote = FactoryGirl.create(:vote, :proposal => @proposal)
      delete :destroy, {:id => vote.to_param, :proposal_id => @proposal.id}
      expect(response).to redirect_to(root_path)
    end
    describe "as admin" do
      before(:each) do
        sign_out @user
        sign_in @admin_user
      end
      it "destroys the requested vote" do
        vote = FactoryGirl.create(:vote, :proposal => @proposal)
        expect {
          delete :destroy, {:id => vote.to_param, :proposal_id => @proposal.id}
        }.to change(Vote, :count).by(-1)
      end

      it "redirects to the votes list" do
        vote = FactoryGirl.create(:vote, :proposal => @proposal)
        delete :destroy, {:id => vote.to_param, :proposal_id => @proposal.id}
        expect(response).to redirect_to(proposal_url(@proposal))
      end
    end
  end

end
