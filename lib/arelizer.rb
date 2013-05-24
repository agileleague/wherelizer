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
    model_name = parsed[1].extract_const
    method_name = final_method_name(parsed[2])

    options_hash = parsed[3].to_hash
    where = parse_conditions(options_hash[:conditions]) if options_hash[:conditions]
    order = parse_order(options_hash[:order]) if options_hash[:order]

    "#{model_name}#{where}#{order}#{method_name}"
  end

  def final_method_name(method_name)
    ".#{method_name}" unless method_name == :all
  end

  def parse_conditions node
    where = ''

    node.to_hash(false).each do |key, val|
      where += ".where(#{ruby2ruby.process(key)} => #{ruby2ruby.process(val)})"
    end
    where
  end

  def parse_order node
    ".order(#{ruby2ruby.process(node)})"
  end

end
