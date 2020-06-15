class AddUniqueIndexOnNameToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :status, :integer, default: 0
    add_index :products, :name, unique: true
  end
end
