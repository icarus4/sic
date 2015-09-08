require 'open-uri'

class Stock::TwseStockList

  attr_reader :data, :stock_exchange

  def initialize(stock_exchange)
    @stock_exchange = stock_exchange.to_s.upcase

    case @stock_exchange
    when 'SII'
      link = 'http://isin.twse.com.tw/isin/C_public.jsp?strMode=2'
    when 'OTC'
      link = 'http://isin.twse.com.tw/isin/C_public.jsp?strMode=4'
    when 'ROTC'
      link = 'http://isin.twse.com.tw/isin/C_public.jsp?strMode=5'
    else
      raise ArgumentError
    end

    @doc = Nokogiri::HTML(Iconv.conv('utf-8//IGNORE', 'big5', open(link).read))
    parse
  end


  private


    def parse
      trs = []
      target_trs.each do |_tr|
        tr = TR.new(_tr)
        trs << tr if match_pattern?(tr)
      end

      @data = trs.map do |tr|
        { ticker: tr.ticker, name: tr.name, category: tr.category }
      end
    end

    def target_trs
      @doc.css("table.h4 > tr")
    end

    def match_pattern?(tr)
      return false if tr.td_size != 7
      return false unless tr.ticker =~ /^\d{4}$/
      return false if tr.category.blank?

      true
    end


    class TR
      attr_reader :tr
      def initialize(tr)
        @tr = tr
      end

      def ticker
        tr.css('td')[0].content.split(%r{\s*　})[0]
      end

      def name
        tr.css('td')[0].content.split(%r{\s*　})[1]
      end

      def td_size
        tr.css('td').size
      end

      def category
        tr.css('td')[4].try(:content)
      end

      # def stock_exchange
      #   case tr.css('td')[3].try(:content)
      #   when nil
      #     nil
      #   when '上市'
      #     'SII'
      #   when '上櫃'
      #     'OTC'
      #   when '興櫃'
      #     'ROTC'
      #   else
      #     raise ArgumentError
      #   end
      # end
    end
end
