wherelizer
========

Tool for converting pre-arel deprecated ActiveRecord queries into new-style ActiveRecord queries.

Easily available in website form at http://wherelizer.agileleague.com

## Usage

    require 'wherelizer'

    Wherelizer.new( %q|Page.all(:conditions => {:content_id => 5, :name => "Cool"})| ).convert
    => "Page.where(content_id: 5).where(name: \"Cool\")"

    Wherelizer.new( %q|@pages = @blog.pages.first(:conditions => {:content_id => 5, :name => "Cool"})|).convert
    => "@pages = @blog.pages.where(content_id: 5).where(name: \"Cool\").first"

