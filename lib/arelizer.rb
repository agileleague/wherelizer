require 'ruby_parser'
require 'ruby2ruby'
require 'arelizer/sexp_extensions'
require 'pry'

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
    assignment = handle_assignment

    model_name = parsed.extract_receiver
    method_name = handle_method_name
    options_hash = parsed.to_hash

    where = parse_conditions(options_hash[:conditions]) if options_hash[:conditions]
    order = parse_order(options_hash[:order]) if options_hash[:order]

    "#{assignment}#{model_name}#{where}#{order}#{method_name}"
  end

  def handle_assignment
    if parsed.is_type? :lasgn
      assignment = final_assignment(parsed.extract_assignment_target)
      @parsed = @parsed[2]
    end
    assignment
  end

  def handle_method_name
    method_name = parsed.extract_method_name
    if method_name == :find
      first_param = parsed[3]
      @parsed = @parsed[4]
      final_method_name(first_param.extract_val)
    else
      @parsed = @parsed[3]
      final_method_name(method_name)
    end
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
