# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

StockExchange.find_or_create_by!(country: 'Taiwan', symbol: 'SII',  name: '台灣證券交易所')
StockExchange.find_or_create_by!(country: 'Taiwan', symbol: 'OTC',  name: '台灣證券櫃檯買賣中心 - 上櫃')
StockExchange.find_or_create_by!(country: 'Taiwan', symbol: 'ROTC', name: '台灣證券櫃檯買賣中心 - 興櫃')
StockExchange.find_or_create_by!(country: 'Taiwan', symbol: 'PUB',  name: '台灣公發公司')

StockExchange.find_or_create_by!(country: 'China', symbol: 'SSE',  name: '上交所')
StockExchange.find_or_create_by!(country: 'China', symbol: 'SZSE',  name: '深交所')
StockExchange.find_or_create_by!(country: 'China', symbol: 'SME',  name: '中小板')
StockExchange.find_or_create_by!(country: 'China', symbol: 'CN',  name: '創業板')

