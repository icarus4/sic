class AddParsedAtToStatements < ActiveRecord::Migration
  def change
    add_column :statements, :parsed_at, :datetime, index: true
  end
end
