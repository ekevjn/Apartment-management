class CreateCitizens < ActiveRecord::Migration
  def change
    create_table :citizens do |t|
      t.string :name
      t.references :ground, index: true, foreign_key: true
      t.string :government_id
      t.string :hometown
      t.string :phone
      t.string :email
      t.integer :gender
      t.date :dob
      t.string :nationality
      t.boolean :is_water_deal, default: false
      t.integer :del_flg, default: 0

      t.timestamps null: false
    end
  end
end
