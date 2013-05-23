require_relative 'test_helper'

describe Arelizer do

  it 'handles a conditions hash' do
    arelizer = Arelizer.new( %q|WikiPage.all(:conditions => {:campaign_id => source_campaign.id, :name => target_names})|)
    assert_equal %q|WikiPage.where(:campaign_id => source_campaign.id).where(:name => target_names)|, arelizer.convert
  end

  it 'maintains a query for "first"' do
    arelizer = Arelizer.new( %q|WikiPage.first(:conditions => {:campaign_id => source_campaign.id, :name => target_names})|)
    assert_equal %q|WikiPage.where(:campaign_id => source_campaign.id).where(:name => target_names).first|, arelizer.convert
  end

  #TODO: find(:all) and find(:first)

  it 'handles an order hash' do
    arelizer = Arelizer.new( %q|WikiPage.all(:order => 'name asc', :conditions => {:campaign_id => source_campaign.id, :name => target_names})|)
    assert_equal %q|WikiPage.where(:campaign_id => source_campaign.id).where(:name => target_names).order("name asc")|, arelizer.convert
  end

end

