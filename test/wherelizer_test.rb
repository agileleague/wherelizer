require_relative 'test_helper'

describe Wherelizer do

  it 'handles a conditions hash' do
    wherelizer = Wherelizer.new( %q|Page.all(:conditions => {:content_id => source_content.id, :name => target_names})|)
    assert_equal %q|Page.where(content_id: source_content.id).where(name: target_names)|, wherelizer.convert
  end

  it 'handles a numbers and strings as conditions' do
    wherelizer = Wherelizer.new( %q|Page.all(:conditions => {:content_id => 5, :name => "Cool"})|)
    assert_equal %q|Page.where(content_id: 5).where(name: "Cool")|, wherelizer.convert
  end

  it 'maintains a query for "first"' do
    wherelizer = Wherelizer.new( %q|Page.first(:conditions => {:content_id => source_content.id, :name => target_names})|)
    assert_equal %q|Page.where(content_id: source_content.id).where(name: target_names).first|, wherelizer.convert
  end

  it 'handles an order hash' do
    wherelizer = Wherelizer.new( %q|Page.all(:order => 'name asc', :conditions => {:content_id => source_content.id, :name => target_names})|)
    assert_equal %q|Page.where(content_id: source_content.id).where(name: target_names).order("name asc")|, wherelizer.convert
  end

  it 'handles an array conditions with a param.' do
    wherelizer = Wherelizer.new %q|Comment.all( :conditions => ["content_id = ?", source_content.id])|
    assert_equal %q|Comment.where("content_id = ?", source_content.id)|, wherelizer.convert
  end

  it 'handles an array conditions with two params.' do
    wherelizer = Wherelizer.new %q|Comment.all( :conditions => ["content_id = ? AND user_id = ?", source_content.id, 10])|
    assert_equal %q|Comment.where("content_id = ? AND user_id = ?", source_content.id, 10)|, wherelizer.convert
  end

  it 'handles an array conditions with no params.' do
    wherelizer = Wherelizer.new %q|Comment.all( :conditions => ["content_id = 10"])|
    assert_equal %q|Comment.where("content_id = 10")|, wherelizer.convert
  end

  it 'handles string conditions.' do
    wherelizer = Wherelizer.new %q|Comment.all( :conditions => "content_id = 10")|
    assert_equal %q|Comment.where("content_id = 10")|, wherelizer.convert
  end

  it 'handles a variable assignment in front' do
    wherelizer = Wherelizer.new %q|comments = Comment.all( :conditions => "content_id = 10")|
    assert_equal %q|comments = Comment.where("content_id = 10")|, wherelizer.convert
  end

  it 'handles an instance variable assignment in front' do
    wherelizer = Wherelizer.new %q|@comments = Comment.all( :conditions => "content_id = 10")|
    assert_equal %q|@comments = Comment.where("content_id = 10")|, wherelizer.convert
  end

  it 'is idempotent' do
    wherelizer = Wherelizer.new %q|comments = Comment.all( :conditions => "content_id = 10")|
    assert_equal %q|comments = Comment.where("content_id = 10")|, wherelizer.convert
    assert_equal %q|comments = Comment.where("content_id = 10")|, wherelizer.convert
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
    wherelizer = Wherelizer.new %q|System.all(:select => 'systems.*, count(systems.id) AS count', :joins => :contents, :group => 'id')|
    assert_equal %q|System.select("systems.*, count(systems.id) AS count").joins(:contents).group("id")|, wherelizer.convert
  end

  it 'handles include and limit' do
    wherelizer = Wherelizer.new %q|Content.all( :conditions => {:id => 1}, :order => "contents.id ASC", :include => [:user, :system], :limit => @limit, :offset => @start)|
    assert_equal %q|Content.where(id: 1).order("contents.id ASC").includes([:user, :system]).limit(@limit).offset(@start)|, wherelizer.convert
  end

  it 'handles method calls in receiver' do
    wherelizer = Wherelizer.new %q|@friend_contents = @content.friends.all(:order => 'id ASC')|
    assert_equal %q|@friend_contents = @content.friends.order("id ASC")|, wherelizer.convert
  end

  it 'handles several method calls in receiver' do
    wherelizer = Wherelizer.new %q|@friend_contents = @content.parent_content.parent_content.friends.all(:order => 'id ASC')|
    assert_equal %q|@friend_contents = @content.parent_content.parent_content.friends.order("id ASC")|, wherelizer.convert
  end

  it 'explains why it cant use a conditions variable' do
    skip("TODO: Implement conditions variable usage or a good exception here")
    wherelizer = Wherelizer.new %q|contents = Content.all( :conditions => conditions, :order => "contents.id ASC", :include => [:user, :system], :limit => @limit, :offset => @start)|
  end

  it 'handles strings in conditions hash keys' do
    wherelizer = Wherelizer.new( %q|Page.all(:conditions => {'pages.content_id' => 5, :name => "Cool"})|)
    assert_equal %q|Page.where("pages.content_id" => 5).where(name: "Cool")|, wherelizer.convert
  end

end

