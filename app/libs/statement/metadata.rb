class Statement::Metadata

  attr_reader :stock, :year, :quarter, :type

  def initialize(stock:, year:, quarter:, type: type)
    @type = fetch_type(type)
    @year = year
    @quarter = quarter
    @stock = fetch_stock(stock)
  end

  def consolidated?
    type == 'consolidated'
  end

  def individual?
    type == 'individual'
  end

  def ticker
    stock.ticker
  end

  private


    def fetch_type(_type)
      return 'consolidated' if _type.nil?

      type = _type.to_s.downcase
      case type
      when 'c', 'consolidated'
        'consolidated'
      when 'i', 'individual'
        'individual'
      else
        raise ArgumentError, "type should be c (consolidated) or i (individual)"
      end
    end

    def fetch_stock(stock)
      return Stock.find_by!(ticker: stock) if stock.is_a?(String)
      return stock if stock.is_a?(Stock)
      raise ArgumentError
    end

end
