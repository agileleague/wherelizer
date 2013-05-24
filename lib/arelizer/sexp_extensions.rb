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

  def to_hash(process_keys=true)
    result = {}
    self[1..-1].each_slice(2) do |key, val|
      result[process_keys ? key.extract_val : key] = val
    end
    result
  end

end
