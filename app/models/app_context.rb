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
# *page*: the page structure
# *menu*: the menu of this page
# *sidebar*: the sidebar of this page
# 
#  
# == Extend
#  You can define even more attributes in the app context or sub-field of the app context(such as app page)
#  your skin or frame renderer should aware all those extended attributes
# 
class AppContext
  # construction attributes
  attr_reader :controller, :action
  # the skin
  attr_accessor :skin

  attr_reader :page

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
  def initialize(controller, action)
    @controller = controller.to_s
    @action     = action.to_s
    @skin     = "basic"
    @page       = AppPage.new
    @selected_path = [nil, nil, nil]
  end

  # Context被用于另外的动作场景
  def update(controller, action)
    @controller = controller
    @action = action
    # 更新Theme中动作的名称
    @theme.resource = resource unless @theme.customized?(:resource)
    @theme.operation = operation unless @theme.customized?(:operation)
    self
  end

  def menu=(menu_name)
    found = MenuLoader.instance.link_groups[menu_name]
    raise format("Can't find link group(menu) with name = '%s'", menu_name) if not found
    @menu = found
  end
  alias_method :current_menu=, :menu=

  def menu(raise_if_nil = true)
    @menu || begin
      msg = format("You havn't configure any menu for this application context controller=%s, action=%s!", @controller, @action)
      raise_if_nil and @controller != 'application' and raise(msg)
    end
  end
  alias_method :current_menu, :menu

  def side_bar=(side_bar_name)
    found = MenuLoader.instance.side_bars[side_bar_name.to_s]
    raise format("Can't find side bar with name = '%s'", side_bar_name) if not found
    @side_bar = found
  end
  alias_method :current_side_bar=, :side_bar=

  def side_bar(raise_if_nil = true)
    @side_bar || begin
      msg = format("You havn't configure any side_bar for this application context controller=%s, action=%s!", @controller, @action)
      raise_if_nil and @controller != 'application' and raise(msg)
    end
  end
  alias_method :current_side_bar, :side_bar

  def selected_path=(path)
    self.selected_menu, self.selected_group, self.selected_link = *path
  end

  # ==设定该上下文中被选中的主菜单项
  def selected_menu=(menu_name)
    if menu_name.blank?
      @selected_path[0] = nil # Clean it
    else
      raise "You can't set selected menu before set page main menu!" unless current_menu
      found = current_menu.links[menu_name.to_s]
      raise format("There is no link: %s in current menu: %s", menu_name, current_menu.name) if not found
      @selected_path[0] = menu_name
    end
  end

  # ==判断主菜单下某菜单项是否被选中
  def selected_menu?(menu_name)
    @selected_path[0].to_s == menu_name.to_s
  end

  # 被选中的主菜单项名称
  def selected_menu_name
    @selected_path.first
  end

  # ==设定该上下文中被选中的SideBar下面的Group
  def selected_group=(group_name)
    if group_name.blank?
      @selected_path[1] = group_name
    else
      raise "You can't set selected group before set page sidebar" unless current_side_bar
      found = current_side_bar.link_groups[group_name.to_s]
      raise format("There is no link group: %s in current sidebar: %s", group_name, current_side_bar.name) if not found
      @selected_path[1] = group_name
    end
  end

  # ==判断当前Sidebar下某Link Group是否被选中
  def selected_group?(group_name)
    @selected_path[1].to_s == group_name.to_s
  end

  # 被选中的SideBar Group名称
  def selected_group_name
    @selected_path[1]
  end

  # ==设定该上下文中被选中的Group下面的Link
  def selected_link=(link_name)
    if( link_name.blank? )
      @selected_path[2] = link_name
    else
      found_group = current_side_bar.link_groups[selected_path[1].to_s]
      raise "You can't set selected link before set selected group in current sidebar" unless found_group
      found = found_group.links[link_name.to_s]
      raise format("There is not link: %s in current selected group: %s", link_name, found_group.name) if not found
      @selected_path[2] = link_name
    end
  end

  # ==判断当前Link Group下某Link是否被选中
  def selected_link?(link_name)
    @selected_path[2].to_s == link_name.to_s
  end

  # ==被选中的LinkGroup下的Link名称
  def selected_link_name
    @selected_path[2]
  end

  # 重新加载AppContext所使用到的菜单和Sidebar
  def reload!
    if self.menu(false)
      selected = self.menu.selected
      self.menu = self.menu.name
      self.menu.selected = selected
    end
    if self.side_bar(false)
      selected = self.side_bar.selected
      self.side_bar = self.side_bar.name 
      self.side_bar.selected = selected
    end
  end

  protected
  # 该ActionContext对应的资源信息
  #  如controller = users时，resource为"用户"
  def resource
    return @controller if @controller == "application"
    model = @controller.classify.constantize
    model.human_name || model.name
  rescue
    @controller.classify
  end
  
  # 该ActionContext对应的操作信息
  #  如action = new时，operation为"新建"
  def operation
    I18n.t(@action, :scope=>%W[#{@controller.singularize} actions], 
                    :raise=>true)
  rescue
    I18n.t(@action, :scope=>%W[activerecord actions], 
                    :default=>@action.to_s.humanize,
                    :raise=>true) rescue @action.to_s.capitalize
  end

  # 让ActionContext从:all到具体action的克隆过程，分离theme,log对象
  def initialize_copy(from)
    @page  = from.page.clone if from.page
    @selected_path = from.selected_path.dup
    if from.menu(false)
      @menu  = from.menu(false).dup
    end
    if from.side_bar(false)
      @side_bar = from.side_bar(false).dup
    end
  end
  
end
