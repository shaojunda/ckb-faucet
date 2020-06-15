# frozen_string_literal: true

class SplitCellService
  def call
    api = SdkApi.instance
    official_account = Account.last
    ckb_wallet = Wallet.new(api: api, from_addresses: official_account.address_hash, for_split: true, collector_type: :default_indexer)
    balance = official_account.balance
    output_balance = Output.where(status: %w(live)).sum(:capacity).to_i
    cells_count = (balance - output_balance) / (207 * 10**8)
    cells_count.times.each_slice(1500) do |items|
      ActiveRecord::Base.transaction do
        to_infos = items.map do
          { "#{official_account.address_hash}": { capacity: 207 * 10**8 } }.stringify_keys
        end
        tx_generator = ckb_wallet.advance_generate(to_infos: to_infos)
        tx = ckb_wallet.advance_sign(tx_generator: tx_generator, contexts: Rails.application.credentials.OFFICIAL_WALLET_PRIVATE_KEY)
        tx_hash = api.send_transaction(tx)
        split_cell = SplitCellEvent.create!(tx_hash: tx_hash)
        save_previous_output(api, split_cell, tx)
        save_output(split_cell, tx, tx_hash)
      end
    end
  end

  def check_transactions
    api = SdkApi.instance
    loop do
      SplitCellEvent.order(:id).where(status: "pending").each do |event|
        tx = api.get_transaction(event.tx_hash)
        if tx.tx_status.status == "committed"
          ActiveRecord::Base.transaction do
            block_hash = tx.tx_status.block_hash
            block = api.get_block(block_hash)
            event.block_hash = block_hash
            event.block_number = block.header.number
            event.completed!
            event.outputs.live.update_all(block_hash: block_hash, block_number: block.header.number)
            event.outputs.collected.update_all(status: "dead")
          end
        end
      end
      break if SplitCellEvent.order(:id).where(status: "pending").count.zero?

      sleep(10)
    end

    puts "done"
  end

  private
    def save_output(split_cell, tx, tx_hash)
      output_values = tx.outputs.each_with_index.map do |output, index|
        lock = output.lock
        type = output.type
        {
            capacity: output.capacity, data: tx.outputs_data[index], split_cell_event_id: split_cell.id,
            lock_args: lock.args, lock_code_hash: lock.code_hash, lock_hash: lock.compute_hash, lock_hash_type: lock.hash_type,
            type_args: type&.args, type_code_hash: type&.code_hash, type_hash: type&.compute_hash, type_hash_type: type&.hash_type,
            output_data_len: CKB::Utils.hex_to_bin(tx.outputs_data[index]).bytesize, cellbase: false,
            tx_hash: tx_hash, cell_index: index, created_at: Time.current, updated_at: Time.current
        }
      end
      Output.upsert_all(output_values, unique_by: %i[tx_hash cell_index])
    end

    def save_previous_output(api, split_cell, tx)
      previous_output_values = tx.inputs.map do |input|
        previous_output = input.previous_output
        tx_with_status = api.get_transaction(previous_output.tx_hash)
        transaction = tx_with_status.transaction
        block_hash = tx_with_status.tx_status.block_hash
        block = api.get_block(block_hash)
        cellbase = transaction.inputs.first.previous_output.tx_hash == "0x0000000000000000000000000000000000000000000000000000000000000000" ? true : false
        cell_index = previous_output.index
        output = transaction.outputs[cell_index]
        lock = output.lock
        type = output.type
        {
            capacity: output.capacity, data: transaction.outputs_data[cell_index], status: "collected", split_cell_event_id: split_cell.id,
            lock_args: lock.args, lock_code_hash: lock.code_hash, lock_hash: lock.compute_hash, lock_hash_type: lock.hash_type,
            type_args: type&.args, type_code_hash: type&.code_hash, type_hash: type&.compute_hash, type_hash_type: type&.hash_type,
            output_data_len: CKB::Utils.hex_to_bin(tx.outputs_data[cell_index]).bytesize, cellbase: cellbase,
            tx_hash: transaction.hash, cell_index: cell_index, created_at: Time.current, updated_at: Time.current, block_hash: block_hash, block_number: block.header.number
        }
      end

      Output.upsert_all(previous_output_values, unique_by: %i[tx_hash cell_index])
    end
end
