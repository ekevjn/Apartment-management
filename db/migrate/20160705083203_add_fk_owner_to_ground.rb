class AddFkOwnerToGround < ActiveRecord::Migration
  def change
    add_foreign_key :grounds, :citizens, column: :owner_id, primary_key: :id
  end
end
