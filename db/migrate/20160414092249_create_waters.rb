class CreateWaters < ActiveRecord::Migration
  def change
    create_table :waters do |t|
      t.references :ground, index: true, foreign_key: true, null: false
      t.integer :water_no, null: false
      t.integer :water_num, default: 0, null: false
      t.integer :num_water_deal, default: 0, null: false
      t.integer :debt, default: 0, limit: 8
      t.integer :paid, default: 0, limit: 8
      t.integer :fee, default: 0, limit: 8
      t.integer :price_water_lv1, default: 0, limit: 8
      t.integer :price_water_lv2, default: 0, limit: 8
      t.integer :price_water_lv3, default: 0, limit: 8
      t.date :started_time, null: false
      t.boolean :is_current, default: true
      t.integer :num_debt, default: 0

      t.timestamps null: false
    end
  end
end
