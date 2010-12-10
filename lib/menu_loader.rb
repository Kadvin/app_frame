# 
# =用于加载菜单
# 菜单有多种形式
# * 一种是单层的菜单组(LinkGroup)
# * 一种是两层的菜单组的组(SideBar)
#
# 一般有两种方式
# * 一种是从YML中加载
# * 一种从数据库中加载
#
module MenuLoader
  class << self
    delegate :link_groups, :side_bars, :to => :instance
    # Use factory-style initialization or insantiate directly from a subclass
    #
    # Options:
    # * <tt>:type</tt> - Name of class as a symbol to instantiate
    #
    # Other options are the same as Fetcher::Base.new
    #
    # Example:
    #
    # MenuLoader.create(:type => :yaml) is equivalent to
    # MenuLoader::Yaml.new
    def create(options = {})
      klass = options.delete(:type)
      raise ArgumentError, 'Must supply a type' unless klass
      module_eval "#{klass.to_s.classify}.new(options)"
    end

    # 初始化菜单加载器实例
    def init(options = {:type=>:yaml})
      @menu_loader = create(options)
    end

    # 获得菜单加载器实例
    def instance
      @menu_loader #||= create(options)
    end

    # 是不是基于DataBase的模式？
    def database?
      Database === @menu_loader
    end

    # 是否已经初始化
    def loaded?
      !!@menu_loader
    end
  end

end
require 'menu_loader/base'
require 'menu_loader/database'
require 'menu_loader/yaml'
