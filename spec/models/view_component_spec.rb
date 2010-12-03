require "spec_helper"

describe ViewComponent do 
  it "should accept symbol as default view component path" do 
    vc = ViewComponent.new(:sample)
    vc.path.should == "view_components/sample"
  end

  it "should accept string as path" do 
    vc = ViewComponent.new("path/to/view/component")
    vc.path.should == "path/to/view/component"
  end

  it "should accept open attribute" do 
    vc = ViewComponent.new("sample")
    vc.open_attribute = "open attribute"
    vc.open_attribute.should == "open attribute"
  end

end