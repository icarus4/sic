class CreateStockExchanges < ActiveRecord::Migration
  def change
    create_table :stock_exchanges do |t|
      t.string :country
      t.string :symbol
      t.string :name

      t.timestamps null: false
    end
  end
end
