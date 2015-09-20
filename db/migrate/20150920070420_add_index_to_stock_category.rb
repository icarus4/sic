class AddIndexToStockCategory < ActiveRecord::Migration
  def change
    add_index :stocks, :category
  end
end
