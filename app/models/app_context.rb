# 
# =Application Context
#
# ==Usage Declare
# The instance of AppContext will exist in every controller
#
# Because controller was created to serve some request identified by url 
# then the attached app_context can provide separate context for every action
#
# Even more, we needn't define the context one by one, and we can reuse in:
# * Class Inheritance 
# * Controller Actions(All actions, some actions)
# two dimension to DRY
# 
# All app contexts are defined by DSL customize(...)
#
# == Detail Introduction
# *controller*: Construction parameter, readonly
#  the controller name binded by this context
#  Eg: UsersController's controller name is *users*
# *action*: Construction parameter, readonly
#  the action name binded by this context, :all means all action
#  Eg: UsersController#index action name is *index*
# 
# *skin*: the skin used by this context, default value is 'basic'
# *structure*: the structure defined by nested view components
# *menu*: the menu of this page
# *sidebar*: the sidebar of this page
# *selections*: such as selected_menu, selected_group, selected_link
#  
# == Extend
#  You can define even more attributes in the app context or sub-field of the app context(such as app page)
#  your skin or frame renderer should aware all those extended attributes
# 
require "ostruct"

class AppContext < OpenStruct
  # stylesheets and javascripts
  attr_reader :stylesheets, :javascripts
  
  # construction attributes
  attr_reader :controller, :action
  
  # the labels of the current context
  attr_reader :label, :subject_label, :action_label

  # the skin
  attr_accessor :skin

  # the structure
  attr_reader :struct
  # you can refer it as structure also
  alias_method :structure, :struct

  #
  # The Selected Path of the Menu/SideBar/LinkGroup
  # It's an array with 3 elements like:
  #  ['merchants', 'merchants_bar', 'merchant']
  # cooresponding to:
  #  * The selected link name in current menu，
  #  * The selected group name in current sidebar
  #  * The selected link name in current link group of current sidebar
  #
  # The reason we put those path info here is:
  #  AppContext is per controller/action per instance
  #  But the LinkGroup/Sidebar is shared in global scope
  #  If we record the selected path in them, it will affect across controller and actions
  #
  attr_reader :selected_path

  # construct an app context
  def initialize(controller, action, skin = "basic")
    @controller = controller.to_s
    @action     = action.to_s
    @skin       = skin
    @javascripts = [:defaults] # default javascripts
    @stylesheets = [@skin] # skin's css is included default
    @struct     = create_default_structure(skin)
    @selected_path = [nil, nil, nil]
    @subject_label = guess_subject_label
    @action_label  = guess_action_label
    @label         = guess_label
    super()
  end

  # 
  # == update self to be used in another scene
  #
  def update(controller, action)
    # puts format("Inherit %s/%s -> %s/%s", @controller, @action, controller, action)
    @controller = controller
    @action = action
    # if the subject or action label was defined, then keep them, or regenrate it again.
    @subject_label = guess_subject_label unless @subject_label_customized
    @action_label  = guess_action_label  unless @action_label_customized
    @label         = guess_label         unless @label_customized
    self
  end

  # 
  # == Set the subject label instead of default
  # 
  def subject_label=(label)
    @subject_label = label
    @subject_label_customized = true
  end

  #
  # == Set the action label instead of default
  #
  def action_label=(label)
    @action_label = label
    @action_label_customized = true
  end

  # 
  # == Set the context label and ignore the subject, action label
  #
  def label=(new_label)
    @label = new_label
    @label_customized = true
  end

  # 
  # == Set current menu
  # set current menu by name
  # if the menu does not exist in the MenuLoader, it will raise error
  #
  def menu=(menu_name)
    found = MenuLoader.link_groups[menu_name]
    raise format("Can't find link group(menu) with name = '%s'", menu_name) if not found
    @menu_name = menu_name
    @menu = found
  end
  alias_method :current_menu=, :menu=

  # 
  # == Get current menu
  # if the menu is not set, you will get an error
  # (Use this anti-pattern to avoid this error report as error caused by nil)
  # you can call this method with: app_context.menu(false) to avoid the error and got a nil object
  #
  def menu(raise_if_nil = true)
    @menu || begin
      msg = format("You havn't configure any menu for this application context controller=%s, action=%s!", @controller, @action)
      raise_if_nil and @controller != 'application' and raise(msg)
    end
  end
  alias_method :current_menu, :menu

  # 
  # == Set the selected *sub*-menu
  # This method set the selection of current menu
  # 
  # Maybe someone think the selected sub-menu was associated with the selected sidebar,
  # but I don't think so, this design leave the max possibility to end-developer to decide 
  # which sidebar to show when a sub-menu was selected
  #
  def selected_menu=(sub_menu_name)
    if sub_menu_name.blank?
      @selected_path[0] = nil # Clean it
    else
      raise "You can't set selected menu before set main menu!" unless @menu
      found = @menu.links[sub_menu_name.to_s]
      raise format("There is no link: %s in current menu: %s", sub_menu_name, @menu.name) if not found
      @selected_path[0] = sub_menu_name
    end
  end

  #
  # == Judge a menu is selected or not?
  #
  def selected_menu?(menu_name)
    @selected_path[0].to_s == menu_name.to_s
  end

  # 
  # == Get current selected *sub*-menu name
  #
  def selected_menu_name
    @selected_path.first
  end

  # 
  # == Set current side bar
  # set current side bar by name
  # if the sidebar does not exist in the MenuLoader, it will raise error
  #
  def side_bar=(side_bar_name)
    found = MenuLoader.side_bars[side_bar_name]
    raise format("Can't find side bar with name = '%s'", side_bar_name) if not found
    @side_bar_name = found
    @side_bar = found
  end
  alias_method :current_side_bar=, :side_bar=

  # 
  # == Get current side bar
  # if the side bar is not set, you will get an error
  # (Use this anti-pattern to avoid this error report as error caused by nil)
  # you can call this method with: app_context.side_bar(false) to avoid the error and got a nil object
  #
  def side_bar(raise_if_nil = true)
    @side_bar || begin
      msg = format("You havn't configure any side_bar for this application context controller=%s, action=%s!", @controller, @action)
      raise_if_nil and @controller != 'application' and raise(msg)
    end
  end
  alias_method :current_side_bar, :side_bar

  #
  # == Set the selected link group in current side bar
  # 
  # You must set the current sidebar first
  # If you set a illegal group name, you will got error also.
  #
  def selected_group=(group_name)
    if group_name.blank?
      @selected_path[1] = group_name
    else
      raise "You can't set selected group before set page sidebar" unless @side_bar
      found = @side_bar.link_groups[group_name.to_s]
      raise format("There is no link group: %s in current sidebar: %s", group_name, @side_bar.name) if not found
      @selected_path[1] = group_name
    end
  end

  #
  # == Judge the group with this name selected or not
  #
  def selected_group?(group_name)
    @selected_path[1].to_s == group_name.to_s
  end

  # 
  # == Get selected group name in current sidebar
  # 
  def selected_group_name
    @selected_path[1]
  end

  #
  # == Set the selected link in current group
  # 
  # You must set the selected group first 
  #
  def selected_link=(link_name)
    if( link_name.blank? )
      @selected_path[2] = link_name
    else
      raise "You can't set selected link before set current side bar" unless @side_bar
      raise "You can't set selected link before set selected group in current sidebar" unless selected_group_name
      group = @side_bar.link_groups[selected_group_name]
      found = group.links[link_name.to_s]
      raise format("There is not link: %s in current selected group: %s", link_name, group.name) if not found
      @selected_path[2] = link_name
    end
  end

  # 
  # == Judge a link was selected in current sidebar's selected group or not
  # 
  def selected_link?(link_name)
    @selected_path[2].to_s == link_name.to_s
  end

  # 
  # == Get current selected link name
  #
  def selected_link_name
    @selected_path[2]
  end

  # 
  # == Set the selected path
  # include the selected sub-menu in current_menu, 
  #             selected group in current side bar
  #             selected link in current group
  #
  def selected_path=(path)
    self.selected_menu, self.selected_group, self.selected_link = *path
  end

  def inspect
    "#<#{self.class} #@controller/#@action>"
  end

  protected
    # 
    # == The subject label of current context guessed from the controller name
    #  Eg: controller = users, subject label = User.human_name
    #  We will try to using the corresponding model's human name
    #
    def guess_subject_label
      return @controller if @controller == "application"
      model = @controller.classify.constantize
      model.human_name || model.name
    rescue
      @controller.classify
    end
    
    # 
    # == The action label of current context guessed from the action name
    #  Eg: action = new, action label = New
    #  We will try to use the i18n resource by this seq:
    #   1. user.actions.new
    #   2. activerecord.actions.new
    #   3. humanize name or capitalize name
    #
    def guess_action_label
      I18n.t(@action, :scope=>%W[#{@controller.singularize} actions], 
                      :raise => true)
    rescue
      I18n.t(@action, :scope=>%W[activerecord actions], 
                      :default=>@action.to_s.humanize,
                      :raise => true) rescue @action.to_s.capitalize
    end

    # 
    # == Guess the label
    #
    def guess_label
      (action_label + subject_label).titleize
    end

    # 
    # Create Default Structure
    #
    def create_default_structure(skin)
      begin
        module_name  = skin.capitalize << "FrameSkin"
        module_klass = module_name.constantize
      rescue 
        raise format("Can't find module klass: %s", module_name)
      end
      module_klass.create_structure
    end
  
    # 
    # == Deep clone the app context
    #  Some objects such as app-page, selected path need to be separated from origin one
    #
    def initialize_copy(from)
      @table = from.table.dup
      @struct  = from.struct.dup if from.struct
      @selected_path = from.selected_path.dup
      @javascripts = from.javascripts.dup
      @stylesheets = from.stylesheets.dup
    end
  
end
