# 
# 代表某个页面组件的对象
#  
require "ostruct" 

class ViewComponent < OpenStruct
  attr_accessor :path

  def initialize(path)
    super()
    self.path = path
  end

  def path=(path)
    @path = case path
    when String then path
    when Symbol then format("view_components/%s", path)
    end
  end

end
