# frozen_string_literal: true

class TransactionGenerator < CKB::TransactionGenerator
  # Build unsigned transaction
  # @param collector [Enumerator] `CellMeta` enumerator
  # @param contexts [hash], key: input lock script hash, value: tx generating context
  # @param fee_rate [Integer] Default 1 shannon / transaction byte
  def generate(collector:, contexts:, fee_rate: 1)
    transaction.outputs.each_with_index do |output, index|
      if type_script = output.type
        if type_handler = CKB::Config.instance.type_handler(type_script)
          output_data = transaction.outputs_data[index]
          cell_meta = CKB::CellMeta.new(api: api, out_point: nil, output: output, output_data_len: CKB::Utils.hex_to_bin(output_data).bytesize, cellbase: false)
          cell_meta.output_data = output_data
          type_handler.generate(cell_meta: cell_meta, tx_generator: self)
        end
      end
    end

    change_output_index = transaction.outputs.rindex { |output| output.capacity == 0 }

    collector.each do |cell_meta|
      lock_script = cell_meta.output.lock
      type_script = cell_meta.output.type
      lock_handler = SingleSignHandler.new(api)
      lock_handler.generate(cell_meta: cell_meta, tx_generator: self, context: contexts[lock_script.compute_hash])
      if type_script
        type_handler = CKB::Config.instance.type_handler(type_script)
        type_handler.generate(cell_meta: cell_meta, tx_generator: self)
      end

      return if enough_capacity?(change_output_index, fee_rate)
    end

    raise "collected inputs not enough"
  end

  def enough_capacity?(change_output_index, fee_rate)
    change_capacity = inputs_capacity - transaction.outputs_capacity
    if change_capacity > 0
      fee = transaction.serialized_size_in_block * fee_rate
      change_capacity = inputs_capacity - transaction.outputs_capacity - fee
    end
    if change_output_index
      change_output = transaction.outputs[change_output_index]
      change_output_data = transaction.outputs_data[change_output_index]
      change_output_occupied_capacity = CKB::Utils.byte_to_shannon(change_output.calculate_bytesize(change_output_data))

      if change_capacity >= change_output_occupied_capacity
        change_output.capacity = change_capacity
        true
      else
        false
      end
    end
  end
end
