class AddPurposeToOutputs < ActiveRecord::Migration[6.0]
  def change
    add_column :outputs, :purpose, :integer, default: 0
  end
end
