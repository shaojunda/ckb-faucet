class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :access_key_id
      t.string :secret_access_key
      t.jsonb :quota_config

      t.timestamps
    end

    add_index(:products, [:access_key_id, :secret_access_key], unique: true)
  end
end
