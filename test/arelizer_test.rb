require_relative 'test_helper'

describe Arelizer do

  it 'handles a conditions hash' do
    arelizer = Arelizer.new( %q|WikiPage.all(:conditions => {:campaign_id => source_campaign.id, :name => target_names})|)
    assert_equal %q|WikiPage.where(:campaign_id => source_campaign.id).where(:name => target_names).all|, arelizer.convert
  end

end

