# == Schema Information
#
# Table name: item_mappings
#
#  id                    :integer          not null, primary key
#  item_id               :integer          not null
#  statement_id          :integer          not null
#  stock_id              :integer          not null
#  stock_exchange_id     :integer          not null
#  stock_ticker          :string
#  stock_exchange_symbol :string
#  value                 :decimal(25, 5)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class ItemMapping < ActiveRecord::Base
  belongs_to :stock_exchange
  belongs_to :stock
  belongs_to :statement
  belongs_to :item, touch: true

  validates :item_id,           presence: true, uniqueness: { scope: :statement_id }
  validates :statement_id,      presence: true
  validates :stock_id,          presence: true
  validates :stock_exchange_id, presence: true
end
