class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.integer :stock_exchange_id
      t.string :stock_exchange_symbol
      t.string :ticker
      t.string :name
      t.string :category

      t.timestamps null: false
    end

    add_index :stocks, [:stock_exchange_id, :ticker], unique: true
    add_index :stocks, :ticker
  end
end
