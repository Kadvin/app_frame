require "spec_helper"
require "basic_skin"
#
# =AppContext is tied with a detailed controller's action
#  to provide context for render the view
#
#  * host:  controller/action (readonly)
#  * label: the label of the context, such as subject, action label (conveniant and settable)
#  * skin:  use which skin
#  * page:  the layout of the view
#  * menu:  current global menu and it's selection
#  * sidebar: current side bar and it's selection
#  * link_group: current link group of the side bar
#  * other: more settings 
#
#  ctx = AppContext.new(controller, action)
#  ctx.label # => action_label + subject_label
#  ctx.label = "xxx"
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

  describe "labels" do 
    def user_model_label; "MyUser" end
    def index_action_label; "Browse " end
    def new_action_label; "Create" end

    before(:each) do 
      controller, action = "users", "index"
      I18n.stub!(:t).with('index', :scope=>%W[user actions], :raise => true).and_return(index_action_label)
      I18n.stub!(:t).with('new', :scope=>%W[operator actions], :raise => true).and_return(new_action_label)
      controller.stub_chain(:classify, :constantize, :human_name).and_return(user_model_label)
      @context = AppContext.new(controller, action)
    end

    it "should guess the subject label as controller's corresponding model human name" do 
      @context.subject_label.should == user_model_label
    end
    
    it "should guess the action_label as resource defined in i18n" do 
      @context.action_label.should == index_action_label
    end
    
    it "should guess the action_label + controller's model name as default context label" do 
      @context.label.should == index_action_label + user_model_label
    end

    it "should guess the action and subject label if developer hasn't customize it while update for other scene" do 
      another = @context.update('operators', 'new')
      another.action_label.should == new_action_label
      another.subject_label.should == 'Operator'
      another.label.should == new_action_label + 'Operator'
    end

    it "should keep the customized action subject and label while update for other scene" do 
      @context.action_label = "MyBrowse"
      another = @context.update('operators', 'new')
      another.action_label.should == "MyBrowse"

      @context.subject_label = "MySubject"
      another = @context.update('operators', 'new')
      another.subject_label.should == 'MySubject'

      @context.label = "MyLabel"
      another = @context.update('operators', 'new')
      another.label.should == 'MyLabel'
      
    end

  end

  describe "menu and sidebar module" do 
    before(:all) do 
      require "menu_loader"
    end

    before(:each) do 
      @context = AppContext.new("users", "index")
      store = mock("menu_loader")
      MenuLoader.stub!(:instance).and_return(store)

      link_group = AppLinkGroup.new(:sample_group)
      link_group.stub!(:links).and_return(HashWithIndifferentAccess.new(:sample_link => AppLink.new(:name => :sample)))
      link_groups = HashWithIndifferentAccess.new(:sample_menu => link_group, :sample_group => link_group)
      store.stub!(:link_groups).and_return(link_groups)
      
      side_bar = AppSideBar.new(:sample)
      side_bar.stub!(:link_groups).and_return(link_groups)
      side_bars =   HashWithIndifferentAccess.new(:sample_side_bar => side_bar)
      
      store.stub!(:side_bars).and_return(side_bars)
    end

    it "should raise error when you set a non-exist menu" do 
      lambda { @context.menu = :no_exist }.should raise_error
    end
   
    it "should accept menu identify and find it smartly" do 
      @context.menu = :sample_menu
      @context.menu.should be_kind_of(AppLinkGroup)
    end
   
    it "should raise error when you set selected to a non-exist link in current menu" do 
      @context.menu = :sample_menu
      lambda { context.selected_menu = :non_exist }.should raise_error
    end
   
    it "should raise error when you set a non-exist sidebar" do 
      lambda { context.side_bar = :non_exist }.should raise_error
    end
   
    it "should accept side_bar identify and find it smartly" do 
      @context.side_bar = :sample_side_bar
      @context.side_bar.should be_kind_of(AppSideBar)
    end
   
    it "should raise error when you select a non-exist group in current sidebar" do 
      @context.side_bar = :sample_side_bar
      lambda{ @context.selected_group = :non_exist }.should raise_error
    end
   
    it "should accept corrent link group and link in the sidebar" do 
      @context.side_bar = :sample_side_bar
      @context.selected_group = :sample_group
      @context.selected_link  = :sample_link
    end
   
    it "should raise error when you select a non-exist link in current sidebar's link group" do 
      @context.side_bar = :sample_side_bar
      @context.selected_group = :sample_group
      lambda {@context.selected_link  = :non_exist}.should raise_error
    end

  end


  describe "duplicate issues" do 
    before(:each) do 
      @context = AppContext.new("users", "index")
    end

    it "should duplicate a separate app_context for other controller or action" do 
      old = @context.dup
      new = @context.update('another_controller', 'another_action')
      
      new.label.should_not == old.label
      
      new.skin = "another"
      new.skin.should_not == old.skin
    
      new.extra = "extra property"
      old.extra.should be_nil
    
      new.struct.extra = "extra_segment"
      old.struct.should_not be_extra
    end
  end


end