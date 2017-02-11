class CreateBuildings < ActiveRecord::Migration
  def change
    create_table :buildings do |t|
      t.string :name
      t.integer :num_floors, null: false
      t.integer :del_flg, default: 0

      t.timestamps null: false
    end
  end
end
