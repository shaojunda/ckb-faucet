# frozen_string_literal: true

class SingleSignHandler < CKB::LockHandlers::SingleSignHandler
  def generate(cell_meta:, tx_generator:, context:)
    super(cell_meta: cell_meta, tx_generator: tx_generator, context: context)
    out_point = cell_meta.out_point
    Output.find_by(tx_hash: out_point.tx_hash, cell_index: out_point.index).collected!
  end
end
