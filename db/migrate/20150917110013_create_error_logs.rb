class CreateErrorLogs < ActiveRecord::Migration
  def change
    create_table :error_logs do |t|
      t.jsonb :data, default: {}, null: false

      t.timestamps null: false
    end
  end
end
