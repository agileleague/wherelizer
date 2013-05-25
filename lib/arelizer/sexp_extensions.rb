module SexpExtensions
  def is_type?(expected_type)
    type = self[0]
    expected_type = [expected_type] unless expected_type.respond_to?(:include?)
    expected_type.include? type
  end

  def check_type(expected_type)
    raise "Unexpected type: #{expected_type} in #{self}" unless is_type?(expected_type)
  end

  def extract_val
    check_type [:lit, :str]
    self[1]
  end

  def extract_const
    check_type :const
    self[1]
  end

  ###
  # Extract the receiver of a method call.
  # Currently we assume this is a constant.
  def extract_receiver
    check_type :call
    self[1].extract_const
  end

  ###
  # Extract the method name of a method call.
  def extract_method_name
    check_type :call
    self[2]
  end

  ###
  # Turn a sexp "hash" node into an actual Ruby hash.
  # If process_keys is true, then we assume the hash keys are strings or symbols,
  #   and extract the actual string or symbol to be the key in the resulting hash.
  # Otherwise, we make the key the whole sexp node that is the key.
  def to_hash(process_keys=true)
    check_type :hash
    result = {}
    self[1..-1].each_slice(2) do |key, val|
      result[process_keys ? key.extract_val : key] = val
    end
    result
  end

  ###
  # Turns a sexp "array" node into an actual Ruby array of just the elements
  def to_array
    check_type :array
    self[1..-1]
  end

end
