require_relative 'test_helper'

describe Arelizer do

  it 'handles a conditions hash' do
    arelizer = Arelizer.new( %q|WikiPage.all(:conditions => {:campaign_id => source_campaign.id, :name => target_names})|)
    assert_equal %q|WikiPage.where(:campaign_id => source_campaign.id).where(:name => target_names)|, arelizer.convert
  end

  it 'handles a numbers and strings as conditions' do
    arelizer = Arelizer.new( %q|WikiPage.all(:conditions => {:campaign_id => 5, :name => "Cool"})|)
    assert_equal %q|WikiPage.where(:campaign_id => 5).where(:name => "Cool")|, arelizer.convert
  end

  it 'maintains a query for "first"' do
    arelizer = Arelizer.new( %q|WikiPage.first(:conditions => {:campaign_id => source_campaign.id, :name => target_names})|)
    assert_equal %q|WikiPage.where(:campaign_id => source_campaign.id).where(:name => target_names).first|, arelizer.convert
  end

  it 'handles an order hash' do
    arelizer = Arelizer.new( %q|WikiPage.all(:order => 'name asc', :conditions => {:campaign_id => source_campaign.id, :name => target_names})|)
    assert_equal %q|WikiPage.where(:campaign_id => source_campaign.id).where(:name => target_names).order("name asc")|, arelizer.convert
  end

  it 'handles an array conditions with a param.' do
    arelizer = Arelizer.new %q|GameContent.all( :conditions => ["campaign_id = ?", source_campaign.id])|
    assert_equal %q|GameContent.where("campaign_id = ?", source_campaign.id)|, arelizer.convert
  end

  it 'handles an array conditions with two params.' do
    arelizer = Arelizer.new %q|GameContent.all( :conditions => ["campaign_id = ? AND user_id = ?", source_campaign.id, 10])|
    assert_equal %q|GameContent.where("campaign_id = ? AND user_id = ?", source_campaign.id, 10)|, arelizer.convert
  end

  it 'handles an array conditions with no params.' do
    arelizer = Arelizer.new %q|GameContent.all( :conditions => ["campaign_id = 10"])|
    assert_equal %q|GameContent.where("campaign_id = 10")|, arelizer.convert
  end

  it 'handles string conditions.' do
    arelizer = Arelizer.new %q|GameContent.all( :conditions => "campaign_id = 10")|
    assert_equal %q|GameContent.where("campaign_id = 10")|, arelizer.convert
  end

  it 'handles a variable assignment in front' do
    arelizer = Arelizer.new %q|contents = GameContent.all( :conditions => "campaign_id = 10")|
    assert_equal %q|contents = GameContent.where("campaign_id = 10")|, arelizer.convert
  end

  it 'is idempotent' do
    arelizer = Arelizer.new %q|contents = GameContent.all( :conditions => "campaign_id = 10")|
    assert_equal %q|contents = GameContent.where("campaign_id = 10")|, arelizer.convert
    assert_equal %q|contents = GameContent.where("campaign_id = 10")|, arelizer.convert
  end

  it 'handles find(:all)' do
    arelizer = Arelizer.new %q|User.find(:all, :conditions => {:id => 1})|
    assert_equal %q|User.where(:id => 1)|, arelizer.convert
  end

  it 'handles find(:first)' do
    arelizer = Arelizer.new %q|User.find(:first, :conditions => {:id => 1})|
    assert_equal %q|User.where(:id => 1).first|, arelizer.convert
  end

  it 'handles select, joins, and group' do
    arelizer = Arelizer.new %q|GameSystem.all(:select => 'game_systems.*, count(game_systems.id) AS count', :joins => :campaigns, :group => 'id')|
    assert_equal %q|GameSystem.select("game_systems.*, count(game_systems.id) AS count").joins(:campaigns).group("id")|, arelizer.convert
  end
end

