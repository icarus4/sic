class CreateStatements < ActiveRecord::Migration
  def change
    create_table :statements do |t|
      t.integer :stock_id
      t.integer :stock_exchange_id

      t.integer :year, limit:2
      t.integer :quarter, limit: 2
      t.integer :statement_type

      t.string :stock_ticker
      t.string :stock_exchange_symbol

      t.timestamps null: false
    end

    add_index :statements, :stock_id
    add_index :statements, :stock_ticker
    add_index :statements, [:year, :quarter]
  end
end
