arelizer
========

Tool for converting pre-arel deprecated ActiveRecord queries into new-style ActiveRecord queries.

## Usage

    require 'arelizer'
    
    Arelizer.new( %q|WikiPage.all(:conditions => {:campaign_id => 5, :name => "Cool"})| ).convert
    => "WikiPage.where(campaign_id: 5).where(name: \"Cool\")"
    
    Arelizer.new( %q|@pages = @blog.pages.first(:conditions => {:campaign_id => 5, :name => "Cool"})|).convert
    => "@pages = @blog.pages.where(campaign_id: 5).where(name: \"Cool\").first"
