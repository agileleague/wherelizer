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
    if parsed.is_type? :lasgn
      assignment = final_assignment(parsed.extract_assignment_target)
      arel_call = parsed[2]
    else
      arel_call = parsed
    end

    model_name = arel_call.extract_receiver
    method_name = final_method_name(arel_call.extract_method_name)

    # TODO: multiple params?
    options_hash = arel_call[3].to_hash
    where = parse_conditions(options_hash[:conditions]) if options_hash[:conditions]
    order = parse_order(options_hash[:order]) if options_hash[:order]

    "#{assignment}#{model_name}#{where}#{order}#{method_name}"
  end

  def final_method_name(method_name)
    ".#{method_name}" unless method_name == :all
  end

  def final_assignment(assignment_target)
    "#{assignment_target} = "
  end

  def parse_conditions node
    where = ''

    if node.is_type? :hash
      node.to_hash(false).each do |key, val|
        where += ".where(#{ruby2ruby.process(key)} => #{ruby2ruby.process(val)})"
      end
    elsif node.is_type? :array
      where = ".where(" + node.to_array.map{ |el| ruby2ruby.process(el) }.join(', ') + ")"
    elsif node.is_type? :str
      where = ".where(#{ruby2ruby.process(node)})"
    else
      raise "Unexpected type for conditions parameter. Expecting hash, array, or string."
    end

    where
  end

  def parse_order node
    ".order(#{ruby2ruby.process(node)})"
  end

end
