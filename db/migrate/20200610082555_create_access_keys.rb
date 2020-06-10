class CreateAccessKeys < ActiveRecord::Migration[6.0]
  def change
    create_table :access_keys do |t|
      t.string :access_key_id, null: false
      t.string :secret_access_key, null: false
      t.integer :status, default: 1
      t.bigint :product_id

      t.timestamps
    end

    add_index(:access_keys, :product_id)
    add_index(:access_keys, :access_key_id, unique: true)
    add_index(:access_keys, :secret_access_key, unique: true)
  end
end
