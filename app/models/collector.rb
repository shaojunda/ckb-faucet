# frozen_string_literal: true

class Collector
  attr_reader :api
  def initialize(api)
    @api = api
  end

  def scanner(lock_hash)
    cell_metas = []
    cell_meta_index = 0
    page = 0
    total_pages = Output.where(lock_hash: lock_hash).page(page).per(100).total_pages
    Enumerator.new do |result|
      loop do
        if cell_meta_index < cell_metas.size
          result << cell_metas[cell_meta_index]
          cell_meta_index += 1
        else
          cell_meta_index = 0
          cell_metas = Output.where(lock_hash: lock_hash).live.page(page).per(100).map do |output|
            output_data_len = output.output_data_len
            cellbase = output.cellbase
            lock = CKB::Types::Script.new(code_hash: output.lock_code_hash, args: output.lock_args, hash_type: output.lock_hash_type)
            type = output.type_code_hash.present? ? CKB::Types::Script.new(code_hash: output.type_code_hash, args: output.type_args, hash_type: output.type_hash_type) : nil

            CKB::CellMeta.new(api: api, out_point: CKB::Types::OutPoint.new(tx_hash: output.tx_hash, index: output.cell_index), output: CKB::Types::Output.new(capacity: output.capacity.to_i, lock: lock, type: type), output_data_len: output_data_len, cellbase: cellbase)
          end
          page += 1
        end

        raise StopIteration if page > total_pages
      end
    end
  end
end
