class TransactionGenerator < CKB::TransactionGenerator
  attr_accessor :transaction, :cell_metas
  attr_reader :api

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