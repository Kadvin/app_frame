# 
# =AppLink: Application Frame Component
#  It present a link in your WEBUI
#  and the link maybe a menu item, a button or a common hyper-link
#  
#  Link's definition in YAML like:
#   name:
#     label:  My Label
#     css:    class name of the link
#     href:   http://the.url.com
#     title:  My Title
#     target: Target Frame
#     other attributes of A
#
require "ostruct"

class AppLink < OpenStruct
  # The identify of the link /Should we define it as common field?
  attr_reader :name

  def initialize(name, attributes = {})
    @name = name.to_s
    attributes.symbolize_keys!
    attributes[:visible] = attributes[:visible].nil? ? true : attributes[:visible]
    # Using my name as default CSS 
    attributes[:css] ||= @name
    super(attributes)
  end
  
  def to_s(options = {})
    new_attrs = modifiable.merge(options)
    label = new_attrs.delete(:label)
    new_attrs.delete(:visible) #this attribute need not output
    css = new_attrs.delete(:css)
    new_attrs[:class] = css if css
    attrs = new_attrs.map{|attr,value| "#{attr}='#{value}'" }.join(" ")
    %Q[<a #{attrs}>#{label}</a>]
  end
end
