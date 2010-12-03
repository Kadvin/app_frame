# 
# =Link Group: Application Framework Component
#  It means a group of links
#  
#  The relationship between Link and LinkGroup is:
#  LinkGroup(*)  ->  Link(*)
# 
require "ostruct"

class AppLinkGroup < OpenStruct

  attr_reader :name, :links

  # To iterate links
  include Enumerable

  # construct the link group by name and attributes
  def initialize(name, attributes = {})
    @name = name
    @links = ActiveSupport::OrderedHash.new
    attributes.symbolize_keys!
    attributes[:visible] = attributes[:visible].nil? ? true : attributes[:visible]
    # Using my name as default CSS 
    attributes[:css] ||= @name
    super(attributes)
  end

  # Add links
  def <<( link )
    @links[link.name.to_s] = link
  end

  # enumerate link
  def each
    @links.each{ |pair| yield(pair.last) }
  end

  alias_method :each_link, :each

  def to_s; label end
end
