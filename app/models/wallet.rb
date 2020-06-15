# frozen_string_literal: true

class Wallet
  attr_reader :api, :input_scripts, :for_split, :collector_type

  def initialize(api:, from_addresses:, collector_type: :default_scanner, for_split: false)
    @api = api
    @for_split = for_split
    @collector_type = collector_type
    @input_scripts = (from_addresses.is_a?(Array) ? from_addresses : [from_addresses]).map do |address|
      CKB::AddressParser.new(address).parse.script
    end
  end

  # Build unsigned transaction
  # @param to_infos [Hash<String, Hash>[]], key: address, value: output infos. eg: { capacity: 1000, type: CKB::Types::Script.new(code_hash: "", args: "", hash_type: ""), data: "0x" }
  # @param contexts [hash], key: input lock script hash, value: tx generating context
  # @param fee_rate [Integer] Default 1 shannon / transaction byte
  def advance_generate(to_infos:, contexts: [], fee_rate: 1)
    outputs = []
    outputs_data = []
    to_infos.each do |info|
      address = info.keys.first
      output_info = info[address]
      script = CKB::AddressParser.new(address).parse.script
      outputs << CKB::Types::Output.new(capacity: output_info[:capacity], lock: script, type: output_info[:type])
      outputs_data << (output_info[:data] || "0x")
    end

    if outputs.all? { |output| output.capacity > 0 }
      outputs << CKB::Types::Output.new(capacity: 0, lock: input_scripts.first, type: nil)
      outputs_data << "0x"
    end
    transaction = CKB::Types::Transaction.new(
      version: 0, cell_deps: [], header_deps: [], inputs: [],
      outputs: outputs, outputs_data: outputs_data, witnesses: []
    )
    tx_generator = TransactionGenerator.new(api, transaction)

    tx_generator.generate(collector: collector, contexts: input_scripts.map(&:compute_hash).zip(contexts).to_h, fee_rate: fee_rate)
    tx_generator
  end

  def advance_sign(tx_generator:, contexts:)
    contexts = (contexts.is_a?(Array) ? contexts : [contexts])
    tx_generator.sign(input_scripts.map(&:compute_hash).zip(contexts).to_h)
    tx_generator.transaction
  end

  private
    def collector
      collector = if collector_type == :default_scanner
        Collector.new(api).scanner(input_scripts.first.compute_hash)
      else
        CKB::Collector.new(api).default_indexer(lock_hashes: input_scripts.map(&:compute_hash))
      end

      Enumerator.new do |result|
        loop do
          cell_meta = collector.next
          if for_split
            collect_cell_for_split(cell_meta, result)
          else
            collect_cell(cell_meta, result)
          end
        rescue StopIteration
          break
        end
      end
    end

    def collect_cell(cell_meta, result)
      if cell_meta.output_data_len == 0 && cell_meta.output.type.nil?
        result << cell_meta
      end
    end

    def collect_cell_for_split(cell_meta, result)
      out_point = cell_meta.out_point
      output = Output.find_by(tx_hash: out_point.tx_hash, cell_index: out_point.index)
      if cell_meta.output_data_len == 0 && cell_meta.output.type.nil? && output.blank?
        result << cell_meta
      end
    end
end
