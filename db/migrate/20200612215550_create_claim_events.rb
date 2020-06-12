class CreateClaimEvents < ActiveRecord::Migration[6.0]
  def change
    enable_extension "pgcrypto"
    create_table :claim_events, id: :uuid do |t|
      t.string :access_key_id
      t.string :request_uuid
      t.string :pk160
      t.string :signature
      t.integer :request_type
      t.string :request_timestamp
      t.decimal :capacity
      t.integer :status, default: 0
      t.string :tx_hash
      t.integer :tx_status, default: 0
      t.integer :created_at_unixtimestamp

      t.timestamps
    end

    add_index(:claim_events, [:id, :tx_hash, :tx_status])
    add_index(:claim_events, :created_at_unixtimestamp)
  end
end
