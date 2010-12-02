# 
# =程序上下文/Application Context
#
# ==作用说明
# 在每个控制器(Controller)的实例中都会存在
#
# 由于每个控制器的实例，都是为某个特定的url请求服务而构造出来的
# 所以，这个AppContext实例就可以做到为每个不同的动作设定上下文环境
#
# 更有甚之，我们并不需要开发者为每个控制器的动作定义上下文，通过在
# * 类继承层次上
# * 控制器的动作层次(所有动作，个别动作）
# 两个维度上进行Inherit and Copy，最大限度的减少重复设定
# (这个功能是通过CustomizeSupport完成的)
#
# ==配置说明
# *controller*: 构造参数，只读
#  该上下文所绑定的控制器名称
#  如UsersController的名称为users
# *action*: 构造参数，只读
#  该上下文所绑定的控制器当前动作名称
#  如UsersController#index的名称为index
# *skin*: 皮肤参数，可读写
#  该参数用于界面采用哪种皮肤，默认是AppFrame提供的sfp(Salesforce Platform)
#  如果你自行开发了，可以使用自行开发的皮肤，相关文档请参考 AppPage
# *theme*: 主题参数，可读，不可直接写（但该对象的属性可写），具体可参见AppTheme文档
# *page*: 页面框架，可读，不可直接写（但该对象的属性可写），具体可参见AppPage文档
# ==备注
# Log/Security等业务策略设置，在从AppFwk剥离AppFrame时移走了，以后可以通过钩子/胶水插进来
# * log是日志记录策略
# * 以后也可以考虑把安全策略放这里
class AppContext
  # * controller是控制器的名称，如UsersController的名称为users
  # * action是动作的名称
  attr_reader :controller, :action
  # 所使用的布局，现在AppFrame支持多套布局方案
  attr_accessor :skin
  # * theme是显示风格
  # * page是页面布局策略
  # * menu是主菜单信息
  # * side_bar是侧栏信息
  # 虽然theme, page, log等对象是只读的
  # 但其中策略是通用的
  attr_reader :theme, :page

  # 当前选中的入口Path
  # 具有三个元素的数组
  #  ['merchants', 'merchants_bar', 'merchant']
  # 对应为:
  #  [主菜单被选中Link名称，Sidebar被选中Group名称, Group中被选中Link名称]
  # 把这些选中状态放在AppContext里面的主要原因是
  #  AppContext基本是每个控制器方法一个实例
  #  LinkGroup/Sidebar等对象是系统全局共享的，如果其记录的选中状态
  #  那么就会导致在每个控制器里面都要记录一份完整的全系统菜单
  #
  attr_reader :selected_path

  # 构造特定动作的上下文
  def initialize(controller, action)
    @controller = controller.to_s
    @action     = action.to_s
    @skin     = "basic"
    @theme      = AppTheme.new(resource, operation)
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
    @theme = from.theme.clone if from.theme
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
