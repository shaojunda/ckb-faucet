# frozen_string_literal: true

class SingleSignHandler < CKB::LockHandlers::SingleSignHandler
  def generate(cell_meta:, tx_generator:, context:)
    super(cell_meta: cell_meta, tx_generator: tx_generator, context: context)
    acp_cell_dep = api.acp_cell_dep
    tx_generator.transaction.cell_deps << acp_cell_dep unless tx_generator.transaction.cell_deps.map(&:to_h).include?(acp_cell_dep.to_h)
    out_point = cell_meta.out_point
    Output.find_by(tx_hash: out_point.tx_hash, cell_index: out_point.index)&.collected!
  end
end
