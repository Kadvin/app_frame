# 
# =菜单加载器的基础模型
#
module MenuLoader
  class Base
    #
    # ==side_bars 侧栏条SmartHash
    # 使用者还可以通过loader.side_bars.admin_bar
    # 这样对象化的方式来获取名为:admin_bar的SideBar对象
    # 
    # ==link_groups 所有链接组的SmartHash
    # 使用者还可以通过loader.link_groups.global_group
    # 这样对象化的方式来获取名为:global_group的Link对象
    #
    attr_reader :side_bars, :link_groups, :options
    def initialize(options)
      @options = options
      load!
    end

    protected
      def load!
        Rails.logger.info "Loading link groups and side bars..."
        @link_groups = load_link_groups
        @side_bars   = load_side_bars
      end
      def load_link_groups
        raise "The concret Menu Loader must implements load_link_groups!"
      end
      def load_side_bars
        raise "The concret Menu Loader must implements load_side_bars!"
      end

    alias_method :reload!, :load!
    public :reload!
  end
end
