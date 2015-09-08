# == Schema Information
#
# Table name: stock_exchanges
#
#  id         :integer          not null, primary key
#  country    :string
#  symbol     :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class StockExchange < ActiveRecord::Base
  has_many :stocks
  has_many :statements
  has_many :item_mappings
  has_many :items, through: :item_mappings, source: :item

  validates :country, presence: true
  validates :symbol,  presence: true, uniqueness: true
  validates :name,    presence: true, uniqueness: true
end
