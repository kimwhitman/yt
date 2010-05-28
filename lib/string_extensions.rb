class String
  def pad_to(number)
    spaces = number - self.length
    spaces.times { self << ' ' } if spaces > 0
    self
  end

  # NOTE: This will not work with the pg gem. It only works with the postgres gem
  def psql_array_to_a
    self[1..-2].split(',')
  end

  # NOTE: This will not work with the pg gem. It only works with the postgres gem
  def psql_array_to_a_i
    self[1..-2].split(',').collect { |num| num.to_i }
  end

  # NOTE: This will not work with the pg gem. It only works with the postgres gem
  def psql_array_to_a_f
    self[1..-2].split(',').collect { |num| num.to_f }
  end

  def sanitize
    self.gsub(/\\/, '\&\&').gsub(/'/, "''").gsub(';','')
  end
end