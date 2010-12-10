begin
  # In order to avoid strange bugs, we load those model first
  %W{app_context app_link
     app_link_group app_side_bar view_component}.each do |file|
    require file
  end
  require 'customize_support'
  # Attach to Rails
  ActionController::Base.extend CustomizeSupport::ClassMethods
  ActionController::Base.send(:include, CustomizeSupport::InstanceMethods, CustomizeSupport::SharedMethods)
  ActionController::Base.send(:helper, :app_frame)
  ActionView::Base.send(:include, CustomizeSupport::SharedMethods)
  ActionView::Base.send(:include, ViewComponentAware)
rescue
  raise $! unless Rails.env.production?
end
