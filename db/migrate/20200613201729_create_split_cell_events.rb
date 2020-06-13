class CreateSplitCellEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :split_cell_events do |t|
      t.string :tx_hash
      t.decimal :block_number, precision: 30
      t.string :block_hash
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
