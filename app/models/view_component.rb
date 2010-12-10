# The default page structure like this:
# 
# (It's support by a defaut view: app_page
#  The Main is mandatory, all others are optional)
#
#
#  The frame was sensitive to the component you specified:
#   vc.main = :plain
#  It's equal to:
#   vc.main = ViewComponent.new(:plain)
#
# 
require "ostruct" 

class ViewComponent < OpenStruct
  attr_accessor :path
  attr_reader   :locals

  def initialize(path)
    super()
    self.path = path
    @locals = HashWithIndifferentAccess.new
  end

  def path=(path)
    @path = case path
    when String then path
    when Symbol then format("view_components/%s", path)
    end
  end

  # 
  # Enhance this class's Method Missing to set sub view component easily
  #  You can follow those sample:
  #  vc.left = :default_component_name # => sidebar, titlebar, helpbar... 
  #               # all view partial name (as symbol) in your skin's view_component path
  #  vc.left = 'path/to/view/partial'
  #  vc.has_left?  # => judge left view component exist or not
  #  vc.left   # => get the view component in left(position)
  #
  def method_missing_with_qaw(name, *args, &block)
    name.to_s =~ /(\w+)(=|\?)/
    symbol, tail = $1, $2
    if (tail == "=" and args.size == 1) #page.main = :xxx等方式设置其中间的component
      method_missing_without_qaw(name, wrap(args.first), &block)
      # Once the attribute was set, OpenStruct will generate a method, so logic in here was skipped
      class << self; self; end.class_eval do  
        undef_method(name)
        define_method(name) { |x| modifiable[symbol.to_sym] = wrap(x)  }
      end
    elsif (tail == "?") # page.has_left?等方式询问其左边是否有component
      symbol =~ /has_(\w+)/
      if $1
        !!self.send($1)
      else
        method_missing_without_qaw(name, *args, &block)
      end
    else
      method_missing_without_qaw(name, *args, &block)
    end
  end
  # qaw = Query And Wrap
  alias_method_chain :method_missing, :qaw

  def inspect
    "#<#{self.class} #@path>"
  end

    # 
    # == Deep clone the view component
    #
    def initialize_copy(from)
      super(from)
      @locals = from.locals.dup
    end

  private
    def wrap(target)
      case target
        when NilClass then nil
        when Symbol, String then ViewComponent.new(target)
        else target
      end
    end
end
