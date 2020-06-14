# frozen_string_literal: true

class SudtTypeScriptGenerator
  def initialize(uuid)
    @uuid = uuid
  end

  def type_script
    CKB::Types::Script.new(code_hash: code_hash, args: uuid, hash_type: hash_type)
  end

  def code_hash
    if SdkApi.instance.mode == CKB::MODE::MAINNET
      ""
    else
      "0x48dbf59b4c7ee1547238021b4869bceedf4eea6b43772e5d66ef8865b6ae7212"
    end
  end

  def hash_type
    if SdkApi.instance.mode == CKB::MODE::MAINNET
      ""
    else
      "data"
    end
  end

  private
  attr_reader :uuid
end
