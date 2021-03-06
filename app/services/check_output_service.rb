# frozen_string_literal: true

class CheckOutputService
  def call
    api = SdkApi.instance
    tip_block_number = api.get_tip_block_number
    safety_block_number = [tip_block_number - 1000, 0].max

    Output.where("block_number <= ?", safety_block_number).where(checked: false).dead.each do |output|
      out_point = CKB::Types::OutPoint.new(tx_hash: output.tx_hash, index: output.cell_index)
      cell_with_status = api.get_live_cell(out_point)
      output.live! if cell_with_status.cell.present?

      output.update(checked: true)
    end

    Rails.logger.info "CheckOutputService done"
  end
end
