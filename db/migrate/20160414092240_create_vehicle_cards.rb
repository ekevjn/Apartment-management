class CreateVehicleCards < ActiveRecord::Migration
  def change
    create_table :vehicle_cards do |t|
      t.string :card_no, null: false
      t.string :license_no
      t.string :vehicle_type
      t.string :status, default: 'Mới tạo'
      t.references :ground, index: true, foreign_key: true, null: false
      t.references :citizen, index: true, foreign_key: true, null: false
      t.date :started_time
      t.integer :created_fee
      t.date :outdate_time
      t.date :registered_time
      t.string :description

      t.timestamps null: false
    end

    add_index :vehicle_cards, :card_no, unique: true
  end
end
