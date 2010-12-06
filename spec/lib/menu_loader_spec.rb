require "spec_helper"
require "menu_loader"

describe MenuLoader do 

  before(:each) do 
    I18n.locale = 'zh-cn'
    @fixture_root = File.join(File.dirname(__FILE__), '../fixtures')
    Rails = mock("Rails")
    Rails.stub_chain(:logger, :info)
    Rails.stub(:root).and_return(".")
  end

  it "should use YAML Menu loader when I feed options with :type => :yaml" do 
    MenuLoader.create(:type => :yaml).should be_kind_of(MenuLoader::Yaml)
  end

  it "should load link and groups" do 
    ml = MenuLoader.create(:type => :yaml, :link_groups => [File.join(@fixture_root, "link_groups.yml")])
    ml.should have(2).link_groups
    ml.link_groups['global_menu'].should have(2).links
    ml.link_groups['business_group'].should have(2).links
  end

  it "should load sidebars" do 
    ml = MenuLoader.create(:type => :yaml, 
                           :link_groups => [File.join(@fixture_root, "link_groups.yml")], 
                           :side_bars => [File.join(@fixture_root, "side_bars.yml")] )
    ml.should have(2).side_bars
    ml.side_bars['first_bar'].should have(2).link_groups
    ml.side_bars['second_bar'].should have(1).link_group
  end
end