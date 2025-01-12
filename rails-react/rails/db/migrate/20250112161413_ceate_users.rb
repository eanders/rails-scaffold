class CeateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: true
      t.string :first_name, null: false
      t.string :last_name, null: false
    end
  end
end