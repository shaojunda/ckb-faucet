# frozen_string_literal: true

class Output < ApplicationRecord
  enum status: { dead: 0, live: 1, collected: 2 }
  belongs_to :split_cell_event

  def check_output_status
    values = []
    cell_collector.each do |cell|
      values << [cell.out_point.tx_hash, cell.out_point.index]
    end
    current_indexed_out_points = Output.live.pluck(:tx_hash, :cell_index)
    puts "There are cells that have not been indexed" if values.difference(current_indexed_out_points).present?
    puts "There are unknown cells" if current_indexed_out_points.difference(values).present?
  end

  def cell_collector
    collector = CKB::Collector.new(api).default_indexer(lock_hashes: input_scripts.map(&:compute_hash))

    Enumerator.new do |result|
      loop do
        cell_meta = collector.next
        if cell_meta.output_data_len == 0 && cell_meta.output.type.nil? && cell_meta.output.capacity == SplitCellService::DEFAULT_CELL_CAPACITY
          result << cell_meta
        end
      rescue StopIteration
        break
      end
    end
  end
end

# == Schema Information
#
# Table name: outputs
#
#  id                  :bigint           not null, primary key
#  block_hash          :string
#  block_number        :decimal(, )
#  capacity            :decimal(, )
#  cell_index          :integer
#  cellbase            :boolean
#  checked             :boolean          default(FALSE)
#  data                :binary
#  lock_args           :string
#  lock_code_hash      :string
#  lock_hash           :string
#  lock_hash_type      :string
#  output_data_len     :integer
#  status              :integer          default("live")
#  tx_hash             :string
#  type_args           :string
#  type_code_hash      :string
#  type_hash           :string
#  type_hash_type      :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  split_cell_event_id :bigint
#
# Indexes
#
#  index_outputs_on_split_cell_event_id     (split_cell_event_id)
#  index_outputs_on_status                  (status) WHERE (status = 1)
#  index_outputs_on_tx_hash_and_cell_index  (tx_hash,cell_index) UNIQUE
#
