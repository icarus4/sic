# == Schema Information
#
# Table name: items
#
#  id             :integer          not null, primary key
#  name           :string
#  has_value      :boolean          not null
#  parent_id      :integer
#  lft            :integer
#  rgt            :integer
#  depth          :integer          default(0), not null
#  children_count :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Item < ActiveRecord::Base

  acts_as_nested_set

  has_many :item_mappings
  has_many :statements,     through: :item_mappings, source: :statement
  has_many :stocks,         through: :item_mappings, source: :stock
  has_many :stock_exchange, through: :item_mappings, source: :stock_exchange

  validates :name, uniqueness: { scope: [:parent_id, :has_value] }
end
