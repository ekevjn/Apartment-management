class CreateFacilities < ActiveRecord::Migration
  def change
    create_table :facilities do |t|
      t.string :name
      t.string :status
      t.string :position
      t.references :building, index: true, foreign_key: true
      t.date :buy_time
      t.date :guarantee_time
      t.string :guarantee_company
      t.integer :del_flg, default: 0

      t.timestamps null: false
    end
  end
end
