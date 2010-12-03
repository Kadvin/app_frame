require "spec_helper"

describe AppSideBar do 
  it "should accept name and attributes to create a sidebar" do 
    sidebar = AppSideBar.new("sample", :attribute=>'sample attribute')
    sidebar.name.should == "sample"
    sidebar.attribute.should == "sample attribute"
  end

  it "should accept open attribute" do 
    sidebar = AppSideBar.new("sample")
    sidebar.open_attribute = "open attribute"
    sidebar.open_attribute.should == "open attribute"
  end

  it "should accept link as its child" do 
    sidebar = AppSideBar.new("sample")
    sidebar << group1 = AppLinkGroup.new("group1")
    sidebar << group2 = AppLinkGroup.new("group2")
    sidebar.include?(group1).should be_true
    sidebar.include?(group2).should be_true
  end


end