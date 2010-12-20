begin
  # In order to avoid strange bugs, we load those model first
  %W{app_context app_link
     app_link_group app_side_bar view_component}.each do |file|
    require file
  end
  require 'app_frame'
  # Attach to Rails
  ActionController::Base.extend AppFrame::ClassMethods
  ActionController::Base.send(:include, AppFrame::InstanceMethods, AppFrame::SharedMethods)
  ActionController::Base.send(:helper, :app_frame)
  ActionView::Base.send(:include, AppFrame::SharedMethods)
  ActionView::Base.send(:include, AppFrame::ContextAware)
rescue
  raise $! unless Rails.env.production?
end
