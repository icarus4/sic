class AddStatementTypeAndCategoryToItemMappings < ActiveRecord::Migration
  def up
    add_column :item_mappings, :accounting_standard, :integer
    add_column :item_mappings, :category, :string
    add_index :item_mappings, :category

    Stock.find_each(batch_size: 100) do |stock|
      ItemMapping.where(stock_id: stock.id).update_all(category: stock.category)
    end

    Statement.find_each(batch_size: 100) do |statement|
      accounting_standard = statement.year >= 2013 ? ItemMapping.accounting_standards.fetch('ifrs') : ItemMapping.accounting_standards.fetch('gaap')
      ItemMapping.where(statement_id: statement.id).update_all(accounting_standard: accounting_standard)
    end
  end

  def down
    remove_column :item_mappings, :accounting_standard
    remove_column :item_mappings, :category
  end
end
