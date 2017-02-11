class CreateGroundHistories < ActiveRecord::Migration
  def change
    create_table :ground_histories do |t|
      t.references :ground, index: true, foreign_key: true
      t.references :citizen, index: true, foreign_key: true
      t.date :come_date
      t.date :end_date

      t.timestamps null: false
    end
  end
end
