require "spec_helper"
require "rails/all"
require "customize_support"

describe CustomizeSupport do 
  class SampleController < ActionController::Base
  end
  trap_context = proc do |ctx|
    ctx.skin = "sample skin"
    
    ctx.page.left = "path/to/leftbar"

    ctx.page.top = "path/to/topbar"
    ctx.page.top.params = "sample"
  end

  judge_context = proc do |ctx|
    ctx.skin.should == "sample skin"

    ctx.page.left.path.should == "path/to/leftbar"

    ctx.page.top.path.should == "path/to/topbar"
    ctx.page.top.params.should == "sample"
  end

  it "should blame when developer not feed any actions and block" do 
    lambda{ SampleController.customize(&trap_context) }.should raise_error
    lambda{ SampleController.customize(:any) }.should raise_error
  end

  it "should provide what developer defined as expected" do 
    SampleController.customize(:action, &trap_context)
    ctx = SampleController.context_for(:action)
    judge_context.call(ctx)
  end

  it "should inherit characters from self  :all action context" do 
    SampleController.customize(:all, &trap_context)
    ctx = SampleController.context_for(:action)
    judge_context.call(ctx)
  end

  it "should inherit characters from parent action context" do 
    SampleController.customize(:action, &trap_context)
    class ChildController < SampleController
    end
    judge_context.call(ChildController.context_for(:action))
  end

  it "should inherit characters from parent :all action" do 
    SampleController.customize(:all, &trap_context)
    class ChildController < SampleController
    end
    judge_context.call(ChildController.context_for(:action))
  end

  it "should inherit characters from parent corresponding context precedence to self :all action " do 
    SampleController.customize(:action) do |ctx|
      ctx.skin = "super skin"
    end
    class ChildController < SampleController
      customize(:all) do |ctx|
        ctx.skin = "child all skin"
      end
    end
    ChildController.context_for(:action).skin.should == "super skin"
  end

end