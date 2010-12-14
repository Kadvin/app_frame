require "spec_helper"

describe ViewComponent do 
  it "should accept symbol as named sub component" do 
    vc = ViewComponent.new('path/to/view/component')
    vc.middle = :sample_view_component
    vc.middle.should be_kind_of(ViewComponent)
    vc.middle.path.should == "view_components/sample_view_component"
  end

  it "should accept view partial path as extended sub component" do 
    vc = ViewComponent.new('path/to/view/component')
    vc.middle = "path/to/middle/view/component"
    vc.middle.should be_kind_of(ViewComponent)
    vc.middle.path.should == "path/to/middle/view/component"
  end

  it "should accpet symbol or string as named sub component event it was set" do 
    vc = ViewComponent.new('path/to/view/component')
    vc.middle = :sample_view_component
    vc.middle = "view_components/sample_view_component"
    vc.middle.should be_kind_of(ViewComponent)
    vc.middle.path.should == "view_components/sample_view_component"
  end

  it "should answer exist or not for special DSL like middle?" do 
    vc = ViewComponent.new('path/to/view/component')
    vc.should_not be_has_middle? # means middle does not exist
    vc.middle = "path/to/middle/view/component"
    vc.should be_has_middle? # means middle exist!
  end

  it "should accept symbol as default view component path" do 
    vc = ViewComponent.new(:sample)
    vc.path.should == "view_components/sample"
  end

  it "should accept string as path" do 
    vc = ViewComponent.new("path/to/view/component")
    vc.path.should == "path/to/view/component"
  end

  it "should duplicate a separate view component including its children" do
    vc = ViewComponent.new("path/to/view/component")
    vc.left = ViewComponent.new("path/to/view/component/left")
    vc.right = ViewComponent.new("path/to/view/component/right")
    another = vc.dup
    another.left.path = "path/to/view/another/view/component/left"
    vc.left.path.should_not == another.left.path
    vc.right.path.should == another.right.path
  end


end