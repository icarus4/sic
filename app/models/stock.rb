# == Schema Information
#
# Table name: stocks
#
#  id                    :integer          not null, primary key
#  stock_exchange_id     :integer
#  stock_exchange_symbol :string
#  ticker                :string
#  name                  :string
#  category              :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class Stock < ActiveRecord::Base
  belongs_to :stock_exchange
  has_many :statements
  has_many :item_mappings
  has_many :items, through: :item_mappings, source: :item

  validates :ticker, presence: true, uniqueness: { scope: :stock_exchange_id }
  validates :name,   presence: true
  validates :stock_exchange_id,   presence: true

  include CommonQueryable
end
