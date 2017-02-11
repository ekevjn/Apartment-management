class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.string :content
      t.references :account, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
