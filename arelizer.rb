require 'rubygems'
require 'ruby_parser'
require 'ruby2ruby'

class Arelizer
  attr_accessor :orig, :parsed, :final, :ruby2ruby

  SAMPLE = 'WikiPage.all(:conditions => {:campaign_id => source_campaign.id, :name => target_names})'

  def initialize(orig)
    @orig = orig
    @parsed = RubyParser.new.parse(orig)
    @ruby2ruby = Ruby2Ruby.new
  end

  def convert
    ensure_type parsed, :call
    ensure_type parsed[1], :const
    model_name = parsed[1][1].to_s
    method_name = parsed[2]

    hash = parsed[3]
    where_conditions = parse_conditions(hash)

    "#{model_name}#{where_conditions}.#{method_name}"
  end

  def parse_conditions node
    ensure_conditions(node)
    contents = node[2]
    ensure_type(contents, :hash)
    where = ''

    keys_and_vals = contents[1..-1]
    keys_and_vals.each_slice(2) do |key, val|
      where += ".where(#{ruby2ruby.process(key)} => #{ruby2ruby.process(val)})"
    end
    where
  end

  def hash_name(node)
    ensure_type(node, :hash)
    ensure_type(node[1], :lit)
    node[1][1]
  end

  def symbol_name(node)
    ensure_type(node, :lit)
    node[1]
  end

  def ensure_type(saxp, expected_type)
    type = saxp[0]
    raise "Unexpected type: #{expected_type} in #{saxp}" unless expected_type == type
  end

  def ensure_ar_method_name(method_name)
    raise "Unexpected method name: #{method_name}" unless [:all, :first].include?(method_name)
  end

  def ensure_conditions(node)
    raise "This is not the conditions hash: #{node}" unless hash_name(node) == :conditions
  end
end
