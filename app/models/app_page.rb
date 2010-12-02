# 
# =用于管理标准页面体的布局的对象
#
# 默认的Frame由如下结构组成：
#  ----------------------------------|
#  |  App Header                     |
#  |------|--------------------------|
#  |      |  Top Side        |       |
#  | Left |------------------| Right |
#  | Side |                  | Side  |
#  |      |  Main            |       |
#  |      |                  |       |
#  |      |------------------|       |
#  |      |  Bottom Side     |       |
#  |------|--------------------------|
#  |  App Footer                     |
#  ----------------------------------|
#  以上示意中，除App Head和App Foot之外的部分就是App Page
#  它包括Left/Top/Main/Right等四个部分
#  其中Main必须存在,也是缺省存在，其他部分均非必选
#  AppPage中有相应的变量，left, top, main, right，它们的类型均为ViewComponent
#  使用者可以通过：
#   page.main = :plain
#  这也相当于:
#   page.main = ViewComponent::Plain.new
#
#  你也可以设置一个不同的Frame，这样你可能需要一整套Skip
#
require "ostruct"

class AppPage < OpenStruct
  
  def initialize
    self.frame = "app_page"
    # 由于这两个ViewComponent基本是默认存在的，所以默认设置，无需配置
    self.main = ViewComponent.new(:main)
    self.top  = ViewComponent.new(:titlebar)
  end
  

  # 
  # 通过Method Missing的方式实现便捷的Component设置
  #  使用者可以如此:
  #  page.left = :default_component_name # => sidebar, titlebar, helpbar
  #  page.left = 'path/to/view/partial'
  #  page.left?  # => 是否存在left view component
  #  page.left   # => 取出左边的view component
  #
  def method_missing_with_qaw(name, *args, &block)
    name = name.to_s
    method_missing_without_qaw(name, *args, &block) unless( name =~ /(\w+)(=|\?)/ )
    if ($2 == "=" and args.size == 1) #page.main = :xxx等方式设置其中间的component
      target = args.first
      vc = case target
        when NilClass then nil
        when Symbol, String then ViewComponent.new(target)
        else target
      end
      method_missing_without_qaw(name, vc, &block)
    elsif ($2 == "?") #page.left?等方式询问其左边是否有component
      !!self.send($1)
    else
      method_missing_without_qaw(name, *args, &block)
    end
  end
  # qaw = Query And Wrap
  alias_method_chain :method_missing, :qaw
end
