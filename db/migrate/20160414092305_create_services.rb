class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.references :ground, index: true, foreign_key: true, null: false
      t.integer :debt, default: 0, limit: 8
      t.integer :paid, default: 0, limit: 8
      t.integer :fee, default: 0, limit: 8
      t.integer :price_service, default: 8
      t.integer :price_hygiene, default: 8
      t.date :started_time, null: false
      t.boolean :is_current, default: true
      t.integer :num_debt, default: 0

      t.timestamps null: false
    end
  end
end
