require "spec_helper"

describe AppLinkGroup do 
  it "should accept name and attributes to create a link group" do 
    group = AppLinkGroup.new("sample", :attribute=>'sample attribute')
    group.name.should == "sample"
    group.attribute.should == "sample attribute"
  end

  it "should accept open attribute" do 
    group = AppLinkGroup.new("sample")
    group.open_attribute = "open attribute"
    group.open_attribute.should == "open attribute"
  end

  it "should accept link as its child" do 
    group = AppLinkGroup.new("sample")
    group << link1 = AppLink.new("link1")
    group << link2 = AppLink.new("link2")
    group.include?(link1).should be_true
    group.include?(link2).should be_true
  end


end