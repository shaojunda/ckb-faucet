# frozen_string_literal: true

class SdkApi
  include Singleton

  METHOD_NAMES = %w(rpc secp_group_out_point secp_code_out_point secp_data_out_point secp_cell_code_hash dao_out_point dao_code_hash dao_type_hash multi_sign_secp_cell_type_hash multi_sign_secp_group_out_point set_secp_group_dep set_dao_dep inspect genesis_block get_block_by_number genesis_block_hash get_block_hash get_header get_block get_tip_header get_tip_block_number get_cells_by_lock_hash get_transaction get_live_cell send_transaction local_node_info get_current_epoch get_epoch_by_number get_peers tx_pool_info get_block_economic_state get_blockchain_info get_peers_state compute_transaction_hash compute_script_hash secp_cell_type_hash dry_run_transaction calculate_dao_maximum_withdraw deindex_lock_hash get_live_cells_by_lock_hash get_lock_hash_index_states get_transactions_by_lock_hash index_lock_hash get_capacity_by_lock_hash get_header_by_number get_cellbase_output_capacity_details set_ban get_banned_addresses estimate_fee_rate get_block_template submit_block).freeze

  def initialize
    @api = CKB::API.new(host: Rails.application.credentials.CKB_NODE_URL)
    setup_sdk_config
  end

  def mode
    @mode ||= @api.get_blockchain_info.chain == "ckb" ? CKB::MODE::MAINNET : CKB::MODE::TESTNET
  end

  def setup_sdk_config
    config = CKB::Config.instance
    config.set_api(Rails.application.credentials.CKB_NODE_URL)
    config.type_handlers[[sudt_code_hash, sudt_hash_type]] = CKB::TypeHandlers::SudtHandler.new(sudt_cell_tx_hash, sudt_cell_index)
    config.lock_handlers[[acp_code_hash, acp_hash_type]] = AnyoneCanPayHandler.new(acp_cell_tx_hash, acp_cell_index)
  end

  def acp_cell_dep
    acp_group_out_point = CKB::Types::OutPoint.new(
      tx_hash: acp_cell_tx_hash,
      index: acp_cell_index
    )
    CKB::Types::CellDep.new(
      out_point: acp_group_out_point,
      dep_type: "dep_group"
    )
  end

  def acp_code_hash
    if mode == CKB::MODE::MAINNET
      ""
    else
      "0x86a1c6987a4acbe1a887cca4c9dd2ac9fcb07405bbeda51b861b18bbf7492c4b"
    end
  end

  def acp_hash_type
    if mode == CKB::MODE::MAINNET
      ""
    else
      "type"
    end
  end

  def acp_cell_tx_hash
    if mode == CKB::MODE::MAINNET
      ""
    else
      "0x4f32b3e39bd1b6350d326fdfafdfe05e5221865c3098ae323096f0bfc69e0a8c"
    end
  end

  def acp_cell_index
    if mode == CKB::MODE::MAINNET
      ""
    else
      0
    end
  end

  def sudt_code_hash
    if mode == CKB::MODE::MAINNET
      ""
    else
      "0x48dbf59b4c7ee1547238021b4869bceedf4eea6b43772e5d66ef8865b6ae7212"
    end
  end

  def sudt_hash_type
    if mode == CKB::MODE::MAINNET
      ""
    else
      "data"
    end
  end

  def sudt_cell_tx_hash
    if mode == CKB::MODE::MAINNET
      ""
    else
      "0xc1b2ae129fad7465aaa9acc9785f842ba3e6e8b8051d899defa89f5508a77958"
    end
  end

  def sudt_cell_index
    if mode == CKB::MODE::MAINNET
      ""
    else
      0
    end
  end

  METHOD_NAMES.each do |name|
    define_method name do |*params|
      call_rpc(name, params: params)
    end
  end

  def call_rpc(method, params: [])
    @api.send(method, *params)
  end
end
