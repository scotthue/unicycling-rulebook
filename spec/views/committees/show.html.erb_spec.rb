require 'spec_helper'

describe "committees/show", :type => :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
  end

  describe "when a proposal exists" do
    before(:each) do
      @committee = FactoryGirl.create(:committee)
      @proposal = FactoryGirl.create(:proposal)
      @proposals = [@proposal]
      assign(:votes, [
          FactoryGirl.create(:vote, :proposal => @proposal),
          FactoryGirl.create(:vote, :proposal => @proposal)])
      render
    end
    it "should find the proposal title" do
      expect(rendered).to match(@proposal.title)
    end
  end
end
