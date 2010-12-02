require "spec_helper"

#
# AppContext is tied with a detailed controller's action
# to provide context for render the view setup by app-frame
#
#  * host:  controller/action (readonly)
#  * title: the title of the context (conveniant and settable)
#  * skin:  use which skin
#  * page:  the layout of the view
#  * menu:  target and selection
#  * sidebar: target and selection
#  * link_group: target and selection
#  * other: more settings 
#
#  ctx = AppContext.new(controller, action)
#  ctx.title # => actionname+controller_name
#  ctx.title = "xxx"
#  ctx.skin  # "basic"
#  ctx.skin  = "another"
#  ctx.page.header = :menubar
#  ctx.page.left   = :sidebar
#  ctx.page.footer = :simple_menubar
#  ctx.menu        = :sample_menu
#  ctx.sidebar     = :sample_bar
#  ctx.selected_menu  = :sample_menu  # the selected menu  of the menu(:sample_menu)
#  ctx.selected_group = :sample_group # the selected group of the sidebar(:sample_bar)
#  ctx.selected_link  = :sample_link  # the selected link  of the group(:sample_group) in sidebar(:sample_bar)
#  ctx.selected_path = [:sample_menu, :sample_group, :sample_link]
#
describe AppContext do 
  it "should use the action_name + controller's model_name as default title" do 
    context.title.should == action_name + controller_model_name
  end

  it "should raise error when you set a non-exist menu" do 
    lambda { context.menu = :no_exist }.should raise_error
  end

  it "should accept menu identify and find it smartly" do 
    context.menu = :sample_menu
    context.menu.should be_kind_of(AppLinkGroup)
  end

  it "should raise error when you set selected to a non-exist link in current menu" do 
    context.menu = :sample_menu
    lambda { context.selected_menu = :non_exist }.should raise_error
  end

  it "should raise error when you set a non-exist sidebar" do 
    lambda { context.side_bar = :non_exist }.should raise_error
  end

  it "should accept side_bar identify and find it smartly" do 
    context.side_bar = :sample_sidebar
    context.side_bar.should be_kind_of(AppSideBar)
  end

  it "should raise error when you select a non-exist group in current sidebar" do 
    context.side_bar = :sample_sidebar
    lambda{ context.selected_group = :non_exist }.should raise_error
  end

  it "should accept corrent link group and link in the sidebar" do 
    context.side_bar = :sample_sidebar
    context.selected_group = :sample_group
    context.selected_link  = :sample_link
  end

  it "should raise error when you select a non-exist link in current sidebar's link group" do 
    context.side_bar = :sample_sidebar
    context.selected_group = :sample_group
    lambda {context.selected_link  = :non_exist}.should raise_error
  end

  it "should duplicate a separate app_context for other controller or action" do 
    another = context.duplicate('another_controller', 'another_action')
    
    another.title.should_not == context.title
    
    another.skin = "another"
    another.skin.should_not == context.skin

    another.extra = "extra property"
    lambda{ context.extra }.should raise_error

    another.page.extra = "extra_segment"
    context.page.should_not be_extra
  end

end