# 
# =Page: Application Framework Component
#
# The Structure of a html-page
#
# The default page structure like this:
# 
# (It's support by a defaut view: app_page
#  The Main is mandatory, all others are optional)
#
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
#
#  The frame was sensitive to the component you specified:
#   page.main = :plain
#  It's equal to:
#   page.main = ViewComponent.new(:plain)
#
#  If you need using another stucture beside this,
#  you should provide another frame to render the page like this:
#  page.frame = 'my_app_page'
#  and you need a total pack of view components according to your new definitions
#

require "ostruct"

class AppPage < OpenStruct
  attr_reader :frame

  def initialize
    super
    # default frame
    @frame = "app_page"
    # default view components
    # main yield all your real content
    self.main = ViewComponent.new(:main)
    # and use a titlebar should your content context, such as subject and action title
    self.top  = ViewComponent.new(:titlebar)
  end
  

  # 
  # Enhance this class's Method Missing to set view component easily
  #  You can follow those sample:
  #  page.left = :default_component_name # => sidebar, titlebar, helpbar... 
  #               # all view partial name in your skin's view_component path
  #  page.left = 'path/to/view/partial'
  #  page.left?  # => judge left view component exist or not
  #  page.left   # => get the view component in left(position)
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
    elsif (tail == "?") #page.left?等方式询问其左边是否有component
      !!self.send(symbol)
    else
      method_missing_without_qaw(name, *args, &block)
    end
  end
  # qaw = Query And Wrap
  alias_method_chain :method_missing, :qaw
  
  private
    def wrap(target)
      case target
        when NilClass then nil
        when Symbol, String then ViewComponent.new(target)
        else target
      end
    end
end
