# 
# =SideBar: Application Framework Component
#  It represent a sidebar or navigator in your WEBUI
#  
#  The relationship between sidebar, link group and link is:
#  SideBar(*)  ->  LinkGroup(*)  ->  Link(*)
#  
require "ostruct"

class AppSideBar < OpenStruct
  include Enumerable
  # SideBar's special attributes
  attr_reader :name, :link_groups
  
  def initialize( name, attributes = {} )
    @name = name
    @link_groups = ActiveSupport::OrderedHash.new
    attributes.symbolize_keys!
    attributes[:visible] = attributes[:visible].nil? ? true : attributes[:visible]
    # Using my name as default CSS 
    attributes[:css] ||= @name
    super(attributes)
  end
  
  def each
    @link_groups.each { |pair| yield(pair.last) }
  end

  alias_method :each_group, :each

  def <<(link_group)
    @link_groups[link_group.name.to_s] = link_group
  end
end
