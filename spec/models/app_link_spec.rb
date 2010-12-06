require "spec_helper"

describe AppLink do 
  it "should raise error when you feed a link without name" do 
    lambda{link = AppLink.new(:attribute=>"sample")}.should raise_error
  end

  it "should accept attributes to create a link" do 
    link = AppLink.new(:name => "sample", :attribute=>'sample attribute')
    link.name.should == "sample"
    link.attribute.should == "sample attribute"
  end

  it "should be visible defaultly" do 
    link = AppLink.new(:name => "sample")
    link.visible.should == true
  end

  it "should return nil for not defined attribute" do 
    link = AppLink.new(:name => "sample")
    link.not_defined_attribute.should be_nil
  end

  it "should accept open attribute" do 
    link = AppLink.new(:name => "sample")
    link.open_attribute = "open attribute"
    link.open_attribute.should == "open attribute"
  end

  it "should generate a hyper-text link when you call to_s" do 
    link = AppLink.new(:name => "sample", :label => 'Sample', :href => "test")
    link.to_s.should == "<a href='test' class='sample'>Sample</a>"
  end

  it "to_s(options) should take priority than attributes" do 
    link = AppLink.new(:name => "sample", :label => 'Sample', :href => "test")
    link.to_s(:href=>'Pretest').should == "<a href='Pretest' class='sample'>Sample</a>"
  end

end