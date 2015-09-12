class CreateItemMappings < ActiveRecord::Migration
  def change
    create_table :item_mappings do |t|
      t.integer :item_id,            null: false, index: true
      t.integer :statement_id,       null: false, index: true
      t.integer :stock_id,           null: false, index: true
      t.integer :stock_exchange_id,  null: false

      t.string :stock_ticker
      t.string :stock_exchange_symbol

      t.decimal :value, precision: 25, scale: 5

      t.timestamps null: false
    end
  end
end
