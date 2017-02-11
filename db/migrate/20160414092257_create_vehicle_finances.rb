class CreateVehicleFinances < ActiveRecord::Migration
  def change
    create_table :vehicle_finances do |t|
      t.references :vehicle_card, index: true, foreign_key: true, null: false
      t.references :ground, index: true, foreign_key: true, null: false
      t.integer :debt, default: 0, limit: 8
      t.integer :paid, default: 0, limit: 8
      t.integer :fee, default: 0, limit: 8
      t.date :started_time, null: false
      t.boolean :is_current, null: true
      t.integer :num_debt, default: 0

      t.timestamps null: false
    end
  end
end
