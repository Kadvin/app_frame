# 
# =链接组: Application Framework组件
#  代表一组链接或者菜单
#  
#  相关的模型关系为:
#  LinkGroup(*)  ->  Link(*)
# 
class AppLinkGroup
  # 定义LinkGroup有多少开放性属性可以直接从配置文件或者数据库的列中加载而来
  # 开放性属性是非必需的，它是相对于约束性属性而言的
  # LinkGroup的Name，Links就是约束性的，不能缺少的！
  OpenAttributes = %w[css label visible]

  attr_reader :name, :links

  # 运行期加以设置的属性
  attr_reader :selected #表明当前选中的菜单
  # 为了能像数组一样直接遍历其中的Links
  include Enumerable

  # 根据名称和属性构建基本的LinkGroup对象
  def initialize(name, attributes = {})
    @name = name
    @attributes = OpenStruct.new(attributes.slice(*OpenAttributes))
    @attributes['css'] ||= @name #默认的样式名称就是自己的名称
    @attributes['visible'] = @attributes['visible'].nil? ? true : @attributes['visible']
    @links = ActiveSupport::OrderedHash.new
  end

  # 实现添加
  def <<( link )
    @links[link.name.to_s] = link
  end

  # 实现遍历
  def each
    @links.each{ |pair| yield(pair.last) }
  end

  alias_method :each_link, :each

  # ==实现严格，自定义的Selected的设置
  def selected=(link_or_name)
    if link_or_name.blank?
      @selected = nil
    else
      name = (AppLink === link_or_name) ? link_or_name.name : link_or_name
      found = detect{|link| link.name.to_s == name.to_s}
      raise format("Can't select the link with name = '%s', it doesn't exist!", name) if not found
      @selected = name.to_s
    end
  end

  # 判断其中的某个Link是否被选中
  def selected?(link_or_name)
    selected.to_s == case link_or_name
    when String, Symbol then link_or_name.to_s
    when AppLink then link_or_name.name
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
      OpenAttributes.include?(name.to_s) ? @attributes.send(name.to_s) : links[name.to_s]
    else
      super
    end
  end

  def to_s; label end
end
