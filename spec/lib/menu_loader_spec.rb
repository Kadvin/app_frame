require "spec_helper"

describe MenuLoader do 
  it "should use YAML Menu loader when I feed options with :type => :yaml" do 
    MenuLoader.create(:type => :yaml).should be_kind_of(MenuLoader::Yaml)
  end

  it "should load link and groups" do 
    plain_text = %Q{
zh-cn:
  global_menu:
    label: —全局菜单—
    links:
    -  staff_menu:
         label: 个人事务
         url: /efforts
         description: 所有员工入口
    -  pjm_menu:
         label: 项目经理
         url: /project_manager/efforts
         description: 项目经理入口

  business_group:
    label: 业务支撑
    css: bulletin
    links:
    -  staffs_link:
         label: 员工管理
         url: /admin/staffs
    -  projects_link:
         label: 项目管理
         url: /admin/projects
    }
  end

  it "should load sidebar from all yaml files with 'side_bar' as file name"
end