class CreateTowers < ActiveRecord::Migration
  def change
    create_table :towers do |t|
      t.string :name
      t.string :area
      t.string :address
      t.string :phone
      t.string :email
      t.string :password_digest
      t.string :symbol
      t.string :fax
      t.string :taxcode
      t.string :subdomain
      t.string :status
      t.string :manager_name
      t.string :management_board
      t.string :bank_no
      t.string :receiver_name
      t.string :bank_name
      t.string :bank_eng
      t.string :picture
      # for subdomain activation
      t.string :activation_digest
      t.integer :del_flg, default: 1
      # for setting finance
      t.integer :payment_date, default: 1
      t.integer :price_service, default: 0, limit: 8
      t.integer :price_hygiene, default: 0, limit: 8
      t.integer :price_water_lv1, default: 0, limit: 8
      t.integer :price_water_lv2, default: 0, limit: 8
      t.integer :price_water_lv3, default: 0, limit: 8
      t.integer :price_bicycle, default: 0, limit: 8
      t.integer :price_electric_bicycle, default: 0, limit: 8
      t.integer :price_motorbike, default: 0, limit: 8
      t.integer :price_car_4_seat, default: 0, limit: 8
      t.integer :price_car_7_seat, default: 0, limit: 8

      t.timestamps null: false
    end
    add_index :towers, :subdomain, unique: true
    add_index :towers, :email, unique: true
  end
end
