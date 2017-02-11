class DeviseCreateAccounts < ActiveRecord::Migration
  def change
    create_table(:accounts) do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Rememberable
      t.datetime :remember_created_at

      # check registed account
      t.boolean :is_manager, default: false
      t.integer :del_flg, default: 0

      t.timestamps null: false
    end

    add_index :accounts, :email, unique: true
  end
end
