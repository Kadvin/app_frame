require "spec_helper"

describe AppPage do 
  it "should using app_page as frame and provide a titlebar in top and main as default view components" do 
    page = AppPage.new
    page.frame.should == "app_page"
    page.main.should be_kind_of(ViewComponent)
    page.main.path.should == "view_components/main"
    page.top.should be_kind_of(ViewComponent)
    page.top.path.should == "view_components/titlebar"
  end

  it "should accept symbol as named view component" do 
    page = AppPage.new
    page.middle = :sample_view_component
    page.middle.should be_kind_of(ViewComponent)
    page.middle.path.should == "view_components/sample_view_component"
  end

  it "should accept view partial path as extended view component" do 
    page = AppPage.new
    page.middle = "path/to/middle/view/component"
    page.middle.should be_kind_of(ViewComponent)
    page.middle.path.should == "path/to/middle/view/component"
  end

  it "should answer exist or not for special DSL like left?" do 
    page = AppPage.new
    page.should_not be_middle? # means middle does not exist
    page.middle = "path/to/middle/view/component"
    page.should be_middle? # means middle exist!
  end
end