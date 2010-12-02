# 
# =导航条: Application Framework组件
#  代表页面上的导航条
#  
#  相关的模型关系为:
#  SideBar  ->  LinkGroup(*)  ->  Link(*)
#  
class AppSideBar
  include Enumerable
  # SideBar的成员属性，名称为其鉴别标志
  attr_reader :name, :link_groups
  
  # 运行期加以设置的属性
  attr_reader :selected #表明当前选中的LinkGroup

  def initialize( name )
    @name = name
    @link_groups = ActiveSupport::OrderedHash.new
  end
  
  def each
    @link_groups.each { |pair| yield(pair.last) }
  end

  alias_method :each_group, :each

  def <<(link_group)
    @link_groups[link_group.name.to_s] = link_group
  end

  #== 实现严格的选择判断
  def selected=(link_group_or_name)
    if( link_group_or_name.blank? ) # 清除选择
      @selected = nil
    else
      name = (AppLinkGroup === link_group_or_name) ? link_group_or_name.name : link_group_or_name
      found = link_groups[name.to_s]
      raise format("Can't select the link group with name = '%s', it doesn't exist!", name) if not found
      @selected = name.to_s
    end
  end

  def selected_link_name
    selected_link and selected_link.selected
  end

  def selected_link
    selected && @link_groups[selected]
  end

  # 判断其中的某个LinkGroup是否被选中
  def selected?(link_group_or_name)
    selected == case link_group_or_name
    when String, Symbol then link_group_or_name.to_s
    when AppLinkGroup then link_group_or_name.name
    when NilClass then false
    end    
  end

  # 能直接以对象属性的方式访问
  #  * 属性
  #  * Links中的Link
  # 如:
  #  * group.label # => "Global Group"
  #  * group.home  # => #<Link:home>
  def method_missing(name, *args)
    if args.empty?
      group = @link_groups[name.to_s]
      return group if group
    end
    super
  end

end
