class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name

      t.timestamps
      # updated_at
      # created_at
    end
  end
end
