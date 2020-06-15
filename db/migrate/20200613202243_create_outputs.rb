class CreateOutputs < ActiveRecord::Migration[6.0]
  def change
    create_table :outputs do |t|
      t.bigint :split_cell_event_id
      t.string :block_hash
      t.decimal :capacity
      t.integer :cell_index
      t.binary :data
      t.string :lock_args
      t.string :lock_code_hash
      t.string :lock_hash
      t.string :lock_hash_type
      t.integer :output_data_len
      t.integer :status, default: 1
      t.string :tx_hash
      t.string :type_args
      t.string :type_code_hash
      t.string :type_hash
      t.string :type_hash_type
      t.boolean :cellbase
      t.boolean :checked, default: false
      t.decimal :block_number

      t.timestamps
    end
    add_index(:outputs, :split_cell_event_id)
    add_index(:outputs, [:tx_hash, :cell_index], unique: true)
    add_index(:outputs, :status, where: "status = 1")
  end
end
