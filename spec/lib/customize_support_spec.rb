require "spec_helper"


describe CustomizeSupport do 

  trap_context = proc do |ctx|
    ctx.skin = "sample skin"
    ctx.page.top = "topbar"
    ctx.page.top.params = "sample"
  end

  judge_context = proc do |ctx|
    ctx.skin.should == "sample skin"
    ctx.page.top.path.should == "topbar"
    ctx.page.top.params.should == "sample"
  end

  it "should blame when developer not feed any actions and block" do 
    controller_class.customize(&trap_context).should raise_error
    controller_class.customize(:any).should raise_error
  end

  it "should provide what developer defined as expected" do 
    controller_class.customize(:action, &trap_context)
    ctx = controller_class.context_for(:action)
    judge_context.call(ctx)
  end

  it "should inherit characters from self  :all action context" do 
    controller_class.customize(:all, &trap_context)
    ctx = controller_class.context_for(:action)
    judge_context.call(ctx)
  end

  it "should inherit characters from parent action context" do 
    controller_class.customize(:action, &trap_context)
    judge_context.call(child_class.context_for(:action))
  end

  it "should inherit characters from parent :all action" do 
    controller_class.customize(:all, &trap_context)
    judge_context.call(child_class.context_for(:action))
  end

  it "should inherit characters from self :all action precedence to parent action context" do 
    controller_class.customize(:action) do |ctx|
      ctx.skin = "super skin"
    end
    child_class.customize(:all) do |ctx|
      ctx.skin = "child all skin"
    end
    child_class.context_for(:action).skin.should == "child all skin"
  end

end