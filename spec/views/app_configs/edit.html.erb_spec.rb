require 'spec_helper'

describe "app_configs/edit", :type => :view do
  before(:each) do
    @app_config = assign(:app_config, FactoryGirl.build_stubbed(:app_config,
      :rulebook_name => "MyString",
      :front_page => "MyString",
      :faq => "MyString",
      :copyright => "My Copy"
    ))
  end

  it "renders the edit app_config form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => app_configs_path(@app_config), :method => "post" do
      assert_select "input#app_config_rulebook_name", :name => "app_config[rulebook_name]"
      assert_select "textarea#app_config_front_page", :name => "app_config[front_page]"
      assert_select "textarea#app_config_faq", :name => "app_config[faq]"
      assert_select "input#app_config_copyright", :name => "app_config[copyright]"
    end
  end
end
