require 'spec_helper'

describe "committee_members/index" do
  before(:each) do
    @committee = FactoryGirl.create(:committee)
    @cm = assign(:committee_members, [
            FactoryGirl.create(:committee_member, :committee => @committee),
            FactoryGirl.create(:committee_member, :committee => @committee)])
  end

  it "renders a list of proposals" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => @cm.first.committee.to_s, :count => 2
    assert_select "tr>td", :text => @cm.first.user.to_s, :count => 1
    assert_select "tr>td", :text => @cm.last.user.to_s, :count => 1
  end
end