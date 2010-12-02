# 
# 从YAML文件中加载各级菜单
#
require 'ostruct'

module MenuLoader
  class Yaml < Base
    protected
      def default_link_group_paths
        Dir[File.join(Rails.root, "config", "locales", "*link_groups*.yml")]
      end

      def load_link_groups
        yml_files = self.options[:link_groups] || []
        yml_files.concat default_link_group_paths
        yml_files.uniq!
        yml_files.inject(OpenStruct.new) do |total, yml_file|
          parse_from_file(total, yml_file) do |name, definition|
            group = AppLinkGroup.new(name, definition)
            definition['links'].each do |link_def|
              # Linkdef is a hash with just one k-v pair
              link_name, link_attributes = link_def.to_a[0]
              group << AppLink.new(link_name, link_attributes)
            end
            group
          end
          total
        end
      end

      def default_side_bar_paths
        Dir[File.join(RAILS_ROOT, "config", "locales", "*side_bars*.yml")]
      end

      def load_side_bars
        yml_files = self.options[:side_bars] || []
        yml_files.concat default_side_bar_paths
        yml_files.uniq!
        yml_files.inject(OpenStruct.new) do |total, yml_file|
          parse_from_file(total, yml_file) do |name, group_names|
            sidebar = AppSideBar.new(name)
            group_names.each do |group_name|
              link_group = self.link_groups[group_name]
              raise "Can't find the link group with name=%s" % group_name unless link_group
              sidebar << link_group
            end
            sidebar
          end
          total
        end
      end

      def parse_from_file(total, yml_file)
        origin_data = YAML.load_file( yml_file )
        raw_datas = origin_data[I18n.locale.to_s] || {}
        raw_datas.each do |name,definition|
          total[name] = yield(name, definition)
        end
      end
  end
end
