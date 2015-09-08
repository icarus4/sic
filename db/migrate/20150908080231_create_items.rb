class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name,             index: true
      t.boolean :has_value,       null: false
      t.integer :parent_id,       null: true, index: true
      t.integer :lft,             null: true, index: true
      t.integer :rgt,             null: true, index: true
      t.integer :depth,           null: false, default: 0
      t.integer :children_count,  null: false, default: 0

      t.timestamps null: false
    end
  end
end
