class CreateMaintains < ActiveRecord::Migration
  def change
    create_table :maintains do |t|
      t.references :facility, index: true, foreign_key: true
      t.datetime :fixed_time
      t.integer :price, default: 0, limit: 8
      t.string :description
      t.integer :del_flg, default: 0

      t.timestamps null: false
    end
  end
end
