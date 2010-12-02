require "spec_helper"

describe AppLink do 
  it "should accept name and attributes to create a link" do 
    link = AppLink.new("sample", :attribute=>'sample attribute')
    link.name.should == "sample"
    link.attribute.should == "sample attribute"
  end

  it "should accept open attribute" do 
    link = AppLink.new("sample")
    link.open_attribute = "open attribute"
    link.open_attribute.should == "open attribute"
  end

end