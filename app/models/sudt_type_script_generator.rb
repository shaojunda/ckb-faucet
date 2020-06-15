# frozen_string_literal: true

class SudtTypeScriptGenerator
  def initialize(udt_uuid)
    @udt_uuid = udt_uuid
  end

  def type_script
    CKB::Types::Script.new(code_hash: code_hash, args: udt_uuid, hash_type: hash_type)
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
  attr_reader :udt_uuid
end
