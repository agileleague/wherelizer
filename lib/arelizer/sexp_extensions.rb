module SexpExtensions
  def is_type?(expected_type)
    type = self[0]
    expected_type = [expected_type] unless expected_type.respond_to?(:include?)
    expected_type.include? type
  end

  def check_type(expected_type)
    raise "Unexpected type: #{expected_type} in #{self}" unless is_type?(expected_type)
  end

end
