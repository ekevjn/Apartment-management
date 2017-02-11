class CreateCitizenCards < ActiveRecord::Migration
  def change
    create_table :citizen_cards do |t|
      t.string :card_no, null: false
      t.references :ground, index: true, foreign_key: true, null: false
      t.string :status, null: false

      t.timestamps null: false
    end
    add_index :citizen_cards, :card_no, unique: true
  end
end
