module AppFrameHelper

  #
  # == Render the view component 
  # The view component may be not exist,
  # So we will render nothing for this case.
  #
  def render_view_component(vc)
    #line = format("Render View Component: %s with locals: %s", File.join(context.skin, vc.path), vc.locals)
    #Rails.logger.debug(line)
    # Remember old
    old_view_component = @current_view_component
    # Register/Update current view component 
    @current_view_component = vc
    render(:partial => File.join(context.skin, vc.path), :locals => vc.locals.merge(vc)) if vc
    # Restore old
    @current_view_component = old_view_component
  end
end
