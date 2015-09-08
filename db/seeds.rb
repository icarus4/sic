# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

sii = StockExchange.find_or_create_by!(country: 'Taiwan', symbol: 'SII',  name: '台灣證券交易所')
otc = StockExchange.find_or_create_by!(country: 'Taiwan', symbol: 'OTC',  name: '台灣證券櫃檯買賣中心 - 上櫃')
rotc = StockExchange.find_or_create_by!(country: 'Taiwan', symbol: 'ROTC', name: '台灣證券櫃檯買賣中心 - 興櫃')
StockExchange.find_or_create_by!(country: 'Taiwan', symbol: 'PUB',  name: '台灣公發公司')

StockExchange.find_or_create_by!(country: 'China', symbol: 'SSE',  name: '上交所')
StockExchange.find_or_create_by!(country: 'China', symbol: 'SZSE',  name: '深交所')
StockExchange.find_or_create_by!(country: 'China', symbol: 'SME',  name: '中小板')
StockExchange.find_or_create_by!(country: 'China', symbol: 'CN',  name: '創業板')


[sii, otc, rotc].each do |stock_exchange|
  Stock::TwseStockList.new(stock_exchange.symbol).data.each do |stock_data|
    Stock.find_or_create_by!(
      ticker: stock_data[:ticker],
      name: stock_data[:name],
      category: stock_data[:category],
      stock_exchange_id: stock_exchange.id,
      stock_exchange_symbol: stock_exchange.symbol
    )
  end
end
