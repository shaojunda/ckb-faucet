class AddAcpTypeToClaimEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :claim_events, :acp_type, :integer, default: 0
  end
end
