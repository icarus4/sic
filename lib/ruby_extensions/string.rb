class String
  def is_number?
    true if Float(self) rescue false
  end

  def is_not_number?
    !is_number?
  end

  def is_integer?
    true if Integer(self) rescue false
  end

  def is_not_integer?
    !is_integer?
  end
end
