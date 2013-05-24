require 'ruby_parser'
require 'ruby2ruby'
require 'arelizer/sexp_extensions'

class Sexp
  include SexpExtensions
end

class Arelizer
  attr_accessor :orig, :parsed, :final, :ruby2ruby

  def initialize(orig)
    @orig = orig
    @parsed = RubyParser.new.parse(orig)
    @ruby2ruby = Ruby2Ruby.new
  end

  def convert
    parsed.check_type :call
    parsed[1].check_type :const
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
    node.check_type :hash
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
    node.check_type :hash
    node[1].check_type :lit
    node[1][1]
  end

  def var_value(node)
    node.check_type [:lit, :str]
    node[1]
  end

end
