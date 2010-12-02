# 
# App Framework所看到的风格设置
#  

class AppTheme
  attr_reader :resource, :operation, :style
  attr_writer :title
  def initialize(resource, operation)
    @resource = resource
    @operation = operation
    @style = :system
  end
  
  def title 
    @title ||= (@operation + @resource)
  end

  def resource=(resource)
    @resource = resource
    customized[:resource] = true
  end

  def operation=(operation)
    @operation = operation
    customized[:operation] = true
  end

  def style=(style)
    @style = style
    customized[:style] = true
  end

  def customized?(attribute)
    customized[attribute]
  end

  def customized
    @customized ||= {}
  end

  def initialize_copy(from)
    @customized = from.customized.clone
  end
end
