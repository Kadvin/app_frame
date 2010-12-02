require "spec_helper"
require "app_link"

describe AppLink do 
  it "should accept name and attributes to create a link" do 
    link = AppLink.new("sample", :attribute=>'sample attribute')
    link.name.should == "sample"
    link.attribute.should == "sample attribute"
  end

  it "should be visible defaultly" do 
    link = AppLink.new("sample")
    link.visible.should == true
  end

  it "should return nil for not defined attribute" do 
    link = AppLink.new("sample")
    link.not_defined_attribute.should be_nil
  end

  it "should accept open attribute" do 
    link = AppLink.new("sample")
    link.open_attribute = "open attribute"
    link.open_attribute.should == "open attribute"
  end

  it "should generate a hyper-text link when you call to_s" do 
    link = AppLink.new("sample", :label => 'Sample', :href => "test")
    link.to_s.should == "<a href='test'>Sample</a>"
  end

  it "to_s(options) should take priority than attributes" do 
    link = AppLink.new("sample", :label => 'Sample', :href => "test")
    link.to_s(:href=>'Pretest').should == "<a href='Pretest'>Sample</a>"
  end

end