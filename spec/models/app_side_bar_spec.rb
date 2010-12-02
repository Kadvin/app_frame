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

end