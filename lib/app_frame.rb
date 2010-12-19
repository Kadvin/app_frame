# 
# = Customize the WEBUI
#  Define the attributes of the app context associated with the controller/action
#  
module CustomizeSupport
  # For ActionController::Base to Extend
  module ClassMethods
    def self.extended(base)
      base.class_eval do 
        class_inheritable_hash :app_contexts
        self.app_contexts = {}
      end
    end
    #
    # Customize the WEBUI's app context
    #  * actions: :all, or some action names, such as :index, :new
    #  * binding block with this method
    #  
    # Eg:
    #
    # customize(:index, :show) do |ctx|
    #   ctx.skin                 = 'sfp'
    #   ctx.subject_label        = "My Resource"
    #   ctx.action_label         = "My Action"
    #
    #   ctx.page.frame           = "/path/to/view/replace/app_page"
    #   ctx.page.top             = :the_view_component_name or "/path/of/view/partial/"
    #   ctx.page.top.parameter_1 = any_object_as_parameter1
    #   ctx.page.top.parameter_2 = any_object_as_parameter2
    #
    #   ctx.current_menu         = :the_link_group_name_loaded_by_menu_loader
    #   ctx.current_side_bar     = :the_side_bar_name_loaded_by_menu_loader
    #   
    #   ctx.selected_menu        = :the_selected_link_name_of_current_menu
    #   ctx.selected_group       = :the_selected_link_group_name_of_current_side_bar
    #   ctx.selected_link        = :the_selected_link_name_of_selected_group_in_current_side_bar
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
    
    # 
    # == the default context associated with :all
    #
    def default_context
      self.app_contexts[:all] ||= AppContext.new(controller_name, :all)
    end

    # 
    # == the context for action
    #
    def context_for(action)
      self.app_contexts[action.to_sym] ||= default_context.dup.update(controller_name, action)
    end
  end

  # For ActionController::Base to Include
  module InstanceMethods
    def determine_layout_by_context
      context.skin
    end
  end

  # For ActionController::Base, ActionView::Base to Include
  module SharedMethods
    # 
    # == Current Context
    #
    def context
      if ActionView::Base === self
        self.controller.class.context_for(action_name)
      else
        self.class.context_for(action_name)
      end
    end

  end

  # For ActionView::Base to Include
  module ContextAware
    def self.included(base)
      base.class_eval do
        def method_missing_with_context_aware(name, *args, &block)
          if args.empty?
            # puts "Context is: #{context}"
            if( context.respond_to?(name) )
              context.send(name)
            else
              # puts "@current_view_component = #{current_view_component} , name = #{name}"
              if current_view_component and current_view_component.send(name)
                current_view_component.send(name)
              else
                method_missing_without_context_aware(name, *args, &block)
              end
            end
          else
            method_missing_without_context_aware(name, *args, &block)
          end
        end

        alias_method_chain :method_missing, :context_aware
      end
    end
  end
end
