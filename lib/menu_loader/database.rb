# 
# 从数据库中加载各级菜单
#
module MenuLoader
  class Database < Base
    protected
      def load_link_groups
        LinkGroup.all
      end

      def load_side_bars
        SideBar.all
      end
  end
end
