# 
# =通过定制AppContext来定制利用Framework显示的界面
#  
module CustomizeSupport
  module ClassMethods
    #
    # 定制主界面的展现形式
    #  * actions: :all或者指定的几个action名称
    #  还需要传入接受AppContext作为参数的Block，
    #  用于具体微调页面各个方面的特征，具体可以参考AppContext对象的注释
    #  
    #  样例如下:
    # customize(:index, :show) do |ctx|
    #   ctx.skin                 = 'sfp'
    #   ctx.theme.style          = 'blue'
    #   ctx.theme.resource       = "被管资源名称"
    #   ctx.theme.action         = "当前动作名称"
    #   ctx.page.layout          = "/path/to/view/replace/app_page"
    #   ctx.page.top             = :the_view_component_name or "/path/of/view/partial/"
    #   ctx.page.top.parameter_1 = any_object_as_parameter1
    #   ctx.page.top.parameter_2 = any_object_as_parameter2
    #   ctx.menu                 = :the_link_group_name_loaded_by_menu_loader
    #   ctx.side_bar             = :the_side_bar_name_loaded_by_menu_loader
    # end
    #
    def customize(*actions)
      raise "You must specify action at least" if actions.empty?
      actions.each do |action|
        if action.to_sym == :all
          ctx = default_context
        else
          ctx = context_for(action)
        end
        yield(ctx)
      end
      layout :determine_layout_by_context
    end
    
    # 缺省上下文
    def default_context
      unless(default = read_inheritable_attribute(:app_ctx_for_all))
        default = AppContext.new(controller_name, :all)
        write_inheritable_attribute(:app_ctx_for_all, default)
      end
      default
    end
    # 特定动作的Context
    def context_for(action)
      unless ctx = read_inheritable_attribute("app_ctx_for_#{action}".to_sym)
        ctx = default_context.dup.update(controller_name, action)
        write_inheritable_attribute("app_ctx_for_#{action}".to_sym, ctx)
      end
      ctx
    end
  end

  module InstanceMethods
    def determine_layout_by_context
      context.skin
    end
  end
  
  module SharedMethods
    # 当前上下文
    def context
      if ActionView::Base === self
        self.controller.class.context_for(action_name)
      else
        self.class.context_for(action_name)
      end
    end
    # 让View里面可以直接访问到Context的对象
    # Maybe可以采用增加 Binding的方式，就像ActionController对ActionView做的那样？
    def method_missing_with_customize(name, *args, &block)
      if( context.respond_to?(name) )
        context.send(name, *args, &block)
      else
        method_missing_without_customize(name, *args, &block)
      end
    end
    alias_method_chain :method_missing, :customize
  end
end
# 主动附加到ActionController等一系列类上
ActionController::Base.extend CustomizeSupport::ClassMethods
ActionController::Base.send(:include, CustomizeSupport::InstanceMethods)
ActionController::Base.send(:include, CustomizeSupport::SharedMethods)
ActionView::Base.send(:include, CustomizeSupport::SharedMethods)
