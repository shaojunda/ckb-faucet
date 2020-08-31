# frozen_string_literal: true

class SudtTypeScriptGenerator
  def initialize(udt_uuid)
    @udt_uuid = udt_uuid
  end

  def type_script
    CKB::Types::Script.new(code_hash: code_hash, args: udt_uuid, hash_type: hash_type)
  end

  def code_hash
    SdkApi.instance.sudt_code_hash
  end

  def hash_type
    SdkApi.instance.sudt_hash_type
  end

  private
    attr_reader :udt_uuid
end
