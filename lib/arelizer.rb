require 'ruby_parser'
require 'ruby2ruby'

class Arelizer
  attr_accessor :orig, :parsed, :final, :ruby2ruby

  def initialize(orig)
    @orig = orig
    @parsed = RubyParser.new.parse(orig)
    @ruby2ruby = Ruby2Ruby.new
  end

  def convert
    ensure_type parsed, :call
    ensure_type parsed[1], :const
    model_name = parsed[1][1].to_s
    method_name = final_method_name(parsed[2])

    options_hash = {}
    raw_options_hash = parsed[3]
    raw_options_hash[1..-1].each_slice(2) do |key, val|
      options_hash[var_value(key)] = val
    end

    where = parse_conditions(options_hash[:conditions]) if options_hash[:conditions]
    order = parse_order(options_hash[:order]) if options_hash[:order]

    "#{model_name}#{where}#{order}#{method_name}"
  end

  def final_method_name(method_name)
    ".#{method_name}" unless method_name == :all
  end

  def parse_conditions node
    ensure_type(node, :hash)
    where = ''

    node[1..-1].each_slice(2) do |key, val|
      where += ".where(#{ruby2ruby.process(key)} => #{ruby2ruby.process(val)})"
    end
    where
  end

  def parse_order node
    ".order(#{ruby2ruby.process(node)})"
  end

  def hash_name(node)
    ensure_type(node, :hash)
    ensure_type(node[1], :lit)
    node[1][1]
  end

  def var_value(node)
    ensure_type(node, [:lit, :str])
    node[1]
  end

  def ensure_type(node, expected_type)
    type = node[0]
    expected_type = [expected_type] unless expected_type.respond_to?(:include?)
    raise "Unexpected type: #{expected_type} in #{node}" unless expected_type.include?(type)
  end

  def ensure_ar_method_name(method_name)
    raise "Unexpected method name: #{method_name}" unless [:all, :first].include?(method_name)
  end

end
