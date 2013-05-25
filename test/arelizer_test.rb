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
end

