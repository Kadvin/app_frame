begin
  # 部分框架模型，不能指望ActiveSupport::Dependencies自动装载
  # 总是会出现这样那样的问题, 需要自己手工加载
  %W{app_context app_page app_theme app_link
     app_link_group app_side_bar view_component}.each do |file|
    require file
  end
  require 'customize_support'
rescue
  raise $! unless Rails.env == 'production'
end
