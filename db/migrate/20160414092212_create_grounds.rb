class CreateGrounds < ActiveRecord::Migration
  def change
    create_table :grounds do |t|
      t.string :name
      t.integer :area_width, default: 0
      t.integer :area_length, default: 0
      t.string :kind
      t.string :status, default: 'Còn trống'
      t.integer :floor, null: false
      t.references :building, index: true, foreign_key: true
      t.string :images, array: true, default: []
      t.integer :owner_id
      t.integer :num_rooms, default: 0
      t.integer :num_citizens, default: 0
      t.integer :num_citizen_cards, default: 0
      t.integer :num_water_deal, default: 0
      t.integer :del_flg, default: 0

      t.timestamps null: false
    end
    add_index :grounds, :name, unique: true
  end
end
