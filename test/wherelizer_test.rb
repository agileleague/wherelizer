require_relative 'test_helper'

describe Wherelizer do

  it 'handles a conditions hash' do
    wherelizer = Wherelizer.new( %q|WikiPage.all(:conditions => {:campaign_id => source_campaign.id, :name => target_names})|)
    assert_equal %q|WikiPage.where(campaign_id: source_campaign.id).where(name: target_names)|, wherelizer.convert
  end

  it 'handles a numbers and strings as conditions' do
    wherelizer = Wherelizer.new( %q|WikiPage.all(:conditions => {:campaign_id => 5, :name => "Cool"})|)
    assert_equal %q|WikiPage.where(campaign_id: 5).where(name: "Cool")|, wherelizer.convert
  end

  it 'maintains a query for "first"' do
    wherelizer = Wherelizer.new( %q|WikiPage.first(:conditions => {:campaign_id => source_campaign.id, :name => target_names})|)
    assert_equal %q|WikiPage.where(campaign_id: source_campaign.id).where(name: target_names).first|, wherelizer.convert
  end

  it 'handles an order hash' do
    wherelizer = Wherelizer.new( %q|WikiPage.all(:order => 'name asc', :conditions => {:campaign_id => source_campaign.id, :name => target_names})|)
    assert_equal %q|WikiPage.where(campaign_id: source_campaign.id).where(name: target_names).order("name asc")|, wherelizer.convert
  end

  it 'handles an array conditions with a param.' do
    wherelizer = Wherelizer.new %q|GameContent.all( :conditions => ["campaign_id = ?", source_campaign.id])|
    assert_equal %q|GameContent.where("campaign_id = ?", source_campaign.id)|, wherelizer.convert
  end

  it 'handles an array conditions with two params.' do
    wherelizer = Wherelizer.new %q|GameContent.all( :conditions => ["campaign_id = ? AND user_id = ?", source_campaign.id, 10])|
    assert_equal %q|GameContent.where("campaign_id = ? AND user_id = ?", source_campaign.id, 10)|, wherelizer.convert
  end

  it 'handles an array conditions with no params.' do
    wherelizer = Wherelizer.new %q|GameContent.all( :conditions => ["campaign_id = 10"])|
    assert_equal %q|GameContent.where("campaign_id = 10")|, wherelizer.convert
  end

  it 'handles string conditions.' do
    wherelizer = Wherelizer.new %q|GameContent.all( :conditions => "campaign_id = 10")|
    assert_equal %q|GameContent.where("campaign_id = 10")|, wherelizer.convert
  end

  it 'handles a variable assignment in front' do
    wherelizer = Wherelizer.new %q|contents = GameContent.all( :conditions => "campaign_id = 10")|
    assert_equal %q|contents = GameContent.where("campaign_id = 10")|, wherelizer.convert
  end

  it 'handles an instance variable assignment in front' do
    wherelizer = Wherelizer.new %q|@contents = GameContent.all( :conditions => "campaign_id = 10")|
    assert_equal %q|@contents = GameContent.where("campaign_id = 10")|, wherelizer.convert
  end

  it 'is idempotent' do
    wherelizer = Wherelizer.new %q|contents = GameContent.all( :conditions => "campaign_id = 10")|
    assert_equal %q|contents = GameContent.where("campaign_id = 10")|, wherelizer.convert
    assert_equal %q|contents = GameContent.where("campaign_id = 10")|, wherelizer.convert
  end

  it 'handles find(:all)' do
    wherelizer = Wherelizer.new %q|User.find(:all, :conditions => {:id => 1})|
    assert_equal %q|User.where(id: 1)|, wherelizer.convert
  end

  it 'handles find(:first)' do
    wherelizer = Wherelizer.new %q|User.find(:first, :conditions => {:id => 1})|
    assert_equal %q|User.where(id: 1).first|, wherelizer.convert
  end

  it 'handles select, joins, and group' do
    wherelizer = Wherelizer.new %q|GameSystem.all(:select => 'game_systems.*, count(game_systems.id) AS count', :joins => :campaigns, :group => 'id')|
    assert_equal %q|GameSystem.select("game_systems.*, count(game_systems.id) AS count").joins(:campaigns).group("id")|, wherelizer.convert
  end

  it 'handles include and limit' do
    wherelizer = Wherelizer.new %q|Campaign.all( :conditions => {:id => 1}, :order => "campaigns.id ASC", :include => [:game_master, :game_system], :limit => @limit, :offset => @start)|
    assert_equal %q|Campaign.where(id: 1).order("campaigns.id ASC").includes([:game_master, :game_system]).limit(@limit).offset(@start)|, wherelizer.convert
  end

  it 'handles method calls in receiver' do
    wherelizer = Wherelizer.new %q|@public_pcs = @campaign.game_characters.all(:order => 'id ASC')|
    assert_equal %q|@public_pcs = @campaign.game_characters.order("id ASC")|, wherelizer.convert
  end

  it 'handles several method calls in receiver' do
    wherelizer = Wherelizer.new %q|@public_pcs = @campaign.parent_campaign.parent_campaign.game_characters.all(:order => 'id ASC')|
    assert_equal %q|@public_pcs = @campaign.parent_campaign.parent_campaign.game_characters.order("id ASC")|, wherelizer.convert
  end

  it 'explains why it cant use a conditions variable' do
    skip("TODO: Implement conditions variable usage or a good exception here")
    wherelizer = Wherelizer.new %q|campaigns = Campaign.all( :conditions => conditions, :order => "campaigns.id ASC", :include => [:game_master, :game_system], :limit => @limit, :offset => @start)|
  end

  it 'handles strings in conditions hash keys' do
    wherelizer = Wherelizer.new( %q|WikiPage.all(:conditions => {'wiki_pages.campaign_id' => 5, :name => "Cool"})|)
    assert_equal %q|WikiPage.where("wiki_pages.campaign_id" => 5).where(name: "Cool")|, wherelizer.convert
  end

end

