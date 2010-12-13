module AppFrameHelper

  #
  # == Render the view component 
  # The view component may be not exist,
  # So we will render nothing for this case.
  # You'd better feed this method with a vc instead of nil, or I'm not sure about what happens
  #
  def render_view_component(vc)
    #line = format("Render View Component: %s with locals: %s", File.join(context.skin, vc.path), vc.locals)
    #Rails.logger.debug(line)
    # Remember old
    old_view_component = @current_view_component
    # Register/Update current view component 
    @current_view_component = vc
    result = render(:partial => File.join(context.skin, vc.path), :locals => vc.locals.merge(vc)) if vc
    # Restore old
    @current_view_component = old_view_component
    result
  end

  #
  # ==Get current view component when partial was rendering
  #
  # We do not render as this way:
  #  render(:partial => vc,path, :locals=>{:current_view_component => vc, ...})
  # Because the sub-partial(not view component won't aware it
  #
  def current_view_component
    @current_view_component
  end
end
