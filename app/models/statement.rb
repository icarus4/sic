# == Schema Information
#
# Table name: statements
#
#  id                    :integer          not null, primary key
#  stock_id              :integer
#  stock_exchange_id     :integer
#  year                  :integer
#  quarter               :integer
#  statement_type        :integer
#  stock_ticker          :string
#  stock_exchange_symbol :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class Statement < ActiveRecord::Base
  belongs_to :stock_exchange
  belongs_to :stock
  has_many :item_mappings
  has_many :items, through: :item_mappings, source: :item

  validates :stock_id,          presence: true, uniqueness: { scope: [:year, :quarter, :statement_type] }
  validates :stock_exchange_id, presence: true
  validates :year,              presence: true
  validates :quarter,           presence: true
  validates :stock_ticker,      presence: true

  enum statement_type: {
    'consolidated' => 0,
    'individual' => 1
  }

  include CommonQueryable
end
