# 
# =链接: Application Frame组件
#  代表一个界面链接，它可能表现为多种界面元素形式，如菜单，超链接，按钮等
#  
#  Link的定义形式为:
#   name:
#     label: 链接显示
#     url: 链接URL
#     description: 链接描述
#     target: 链接的Target Frame
#     css: 链接的CSS名称
#
class AppLink
  # 链接的属性，以后如果支持更多的属性，需要在这里额外约束
  OpenAttributes = %w[label url description target css onclick visible]
  # 链接的名称
  attr_reader :name
  def initialize(name, attributes)
    @name = name.to_s
    # 只将设定的属性抽取出来
    @attributes = attributes.slice(*OpenAttributes).with_indifferent_access
    @attributes['visible'] = @attributes['visible'].nil? ? true : @attributes['visible']
  end
  
  def method_missing(name, *args)
    if name.to_s =~ /(\w+)=/
      name = $1
      write = true
    else
      name = name.to_s
      write = false
    end
    if( OpenAttributes.include?(name) )
      write ? @attributes[name] = args.first : @attributes[name]
    else
      super
    end
  end
  
  def to_s(options = {})
    new_attrs = @attributes.merge(options)
    new_attrs['title'] = new_attrs.delete('description')
    new_attrs['href'] = new_attrs.delete('url')
    new_attrs['class'] = new_attrs.delete('css')
    label = new_attrs.delete('label')
    attrs = new_attrs.map{|attr,value| "#{attr}='#{value}'" }.join(" ")
    %Q[<a #{attrs}>#{label}</a>]
  end
end
