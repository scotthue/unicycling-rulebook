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

describe RevisionsController do
  before(:each) do
    @proposal = FactoryGirl.create(:proposal)
    @revision = FactoryGirl.create(:revision, :proposal => @proposal, :user_id => @proposal.owner)

    @admin = FactoryGirl.create(:admin_user)
    sign_in @admin
  end

  # This should return the minimal set of attributes required to create a valid
  # Revision. As you add validations to Revision, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { body: "blah",
      change_description: "blaa"}
  end
  
  describe "GET show" do
    it "assigns the requested revision as @revision" do
      revision = FactoryGirl.create(:revision, :proposal => @proposal)
      get :show, {:id => revision.to_param, :proposal_id => @proposal.id}
      assigns(:revision).should eq(revision)
    end
    it "can see the revision of a 'Submitted' proposal as a normal user" do
      user = @proposal.owner
      FactoryGirl.create(:committee_member, :committee => @proposal.committee, :user => user)
      sign_out @admin
      sign_in user
      get :show, {:id => @revision.to_param, :proposal_id => @proposal.id}
      assigns(:revision).should eq(@revision)
      response.should be_success
      response.should render_template("show")
    end
    describe "as an editor" do
      before(:each) do
        @editor = FactoryGirl.create(:user)
        FactoryGirl.create(:committee_member, :committee => @proposal.committee, :user => @proposal.owner)
        FactoryGirl.create(:committee_member, :committee => @proposal.committee, :user => @editor, :editor => true)
        sign_out @admin
      end
      it "can view revisions" do
        sign_in @editor
        get :show, {:id => @revision.to_param, :proposal_id => @proposal.id}
        assigns(:revision).should eq(@revision)
      end
    end
  end

  describe "GET new" do
    it "assigns a new revision as @revision" do
      get :new, {:proposal_id => @proposal.id}
      assigns(:revision).should be_a_new(Revision)
    end
    it "should contain information from previous revision" do
      get :new, {:proposal_id => @proposal.id}
      assigns(:revision).background.should == @proposal.latest_revision.background
      assigns(:revision).body.should == @proposal.latest_revision.body
      assigns(:revision).references.should == @proposal.latest_revision.references
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Revision" do
        expect {
          post :create, {:revision => valid_attributes, :proposal_id => @proposal.id}
        }.to change(Revision, :count).by(1)
      end
      describe "as a normal user" do
        before(:each) do
            sign_out @admin
            @user = FactoryGirl.create(:user)
            @prop = FactoryGirl.create(:proposal, :owner => @user, :status => 'Review')
            cm = FactoryGirl.create(:committee_member, :user => @user, :committee => @prop.committee)
            sign_in @user
        end
        it "can create a revision to my own proposal" do
            post :create, {:revision => valid_attributes, :proposal_id => @prop.id}
            assigns(:revision).should be_persisted
            response.should redirect_to([@prop, Revision.last])
        end
      end
      describe "as an editor" do
        before(:each) do
            sign_out @admin
            @user = FactoryGirl.create(:user)
            @editor = FactoryGirl.create(:user)
            @prop = FactoryGirl.create(:proposal, :owner => @user, :status => 'Review')
            cm = FactoryGirl.create(:committee_member, :user => @user, :committee => @prop.committee)
            cm = FactoryGirl.create(:committee_member, :user => @editor, :editor => true, :committee => @prop.committee)
            sign_in @editor
        end
        it "can create a revision to another proposal" do
            post :create, {:revision => valid_attributes, :proposal_id => @prop.id}
            assigns(:revision).should be_persisted
            response.should redirect_to([@prop, Revision.last])
        end

      end

      it "assigns a newly created revision as @revision" do
        post :create, {:revision => valid_attributes, :proposal_id => @proposal.id}
        assigns(:revision).should be_a(Revision)
        assigns(:revision).should be_persisted
      end

      it "redirects to the created revision" do
        post :create, {:revision => valid_attributes, :proposal_id => @proposal.id}
        response.should redirect_to([@proposal, Revision.last])
        Revision.last.user.should == @admin
        Revision.last.proposal.should == @proposal
      end
      it "sends an e-mail when a new revision is created" do
        ActionMailer::Base.deliveries.clear
        post :create, {:revision => valid_attributes, :proposal_id => @proposal.id}
        num_deliveries = ActionMailer::Base.deliveries.size
        num_deliveries.should == 1
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved revision as @revision" do
        # Trigger the behavior that occurs when invalid params are submitted
        Revision.any_instance.stub(:save).and_return(false)
        post :create, {:revision => {}, :proposal_id => @proposal.id}
        assigns(:revision).should be_a_new(Revision)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Revision.any_instance.stub(:save).and_return(false)
        post :create, {:revision => {}, :proposal_id => @proposal.id}
        response.should render_template("new")
      end
    end
    describe "with a Pre-Voting status proposal" do
        before(:each) do
            @proposal.status = 'Pre-Voting'
            @proposal.save!
        end
        it "should set the status to review" do
          post :create, {:revision => valid_attributes, :proposal_id => @proposal.id}
          assigns(:proposal).status.should == 'Review'
        end
        it "should set the review_start_date and review_end_date" do
          post :create, {:revision => valid_attributes, :proposal_id => @proposal.id}
          ((assigns(:proposal).review_start_date - DateTime.now()) * 1.days).should < 1
          ((assigns(:proposal).review_end_date - DateTime.now()) * 1.days).should > 2
        end
    end
  end
end
