# frozen_string_literal: true

require "test_helper"

class SdkApiTest < ActiveSupport::TestCase
  context "testnet" do
    should "return testnet old acp code hash when acp type is old" do
      blockchain_info = { get_blockchain_info: { chain: "ckt" } }
      api_obj = JSON.parse(blockchain_info.to_json, object_class: OpenStruct)
      CKB::API.stubs(:new).returns(api_obj)
      api = SdkApi.clone.instance
      api.acp_type = "old"
      assert_equal "0x86a1c6987a4acbe1a887cca4c9dd2ac9fcb07405bbeda51b861b18bbf7492c4b", api.acp_code_hash
    end

    should "return testnet old acp hash type when acp type is old" do
      blockchain_info = { get_blockchain_info: { chain: "ckt" } }
      api_obj = JSON.parse(blockchain_info.to_json, object_class: OpenStruct)
      CKB::API.stubs(:new).returns(api_obj)
      api = SdkApi.clone.instance
      api.acp_type = "old"
      assert_equal "type", api.acp_hash_type
    end

    should "return testnet old acp cell tx hash when acp type is old" do
      blockchain_info = { get_blockchain_info: { chain: "ckt" } }
      api_obj = JSON.parse(blockchain_info.to_json, object_class: OpenStruct)
      CKB::API.stubs(:new).returns(api_obj)
      api = SdkApi.clone.instance
      api.acp_type = "old"
      assert_equal "0x4f32b3e39bd1b6350d326fdfafdfe05e5221865c3098ae323096f0bfc69e0a8c", api.acp_cell_tx_hash
    end

    should "return testnet new acp code hash when acp type is new" do
      blockchain_info = { get_blockchain_info: { chain: "ckt" } }
      api_obj = JSON.parse(blockchain_info.to_json, object_class: OpenStruct)
      CKB::API.stubs(:new).returns(api_obj)
      api = SdkApi.clone.instance
      assert_equal "0x3419a1c09eb2567f6552ee7a8ecffd64155cffe0f1796e6e61ec088d740c1356", api.acp_code_hash
    end

    should "return testnet new acp hash type when acp type is new" do
      blockchain_info = { get_blockchain_info: { chain: "ckt" } }
      api_obj = JSON.parse(blockchain_info.to_json, object_class: OpenStruct)
      CKB::API.stubs(:new).returns(api_obj)
      api = SdkApi.clone.instance
      assert_equal "type", api.acp_hash_type
    end

    should "return testnet new acp cell tx hash when acp type is new" do
      blockchain_info = { get_blockchain_info: { chain: "ckt" } }
      api_obj = JSON.parse(blockchain_info.to_json, object_class: OpenStruct)
      CKB::API.stubs(:new).returns(api_obj)
      api = SdkApi.clone.instance
      assert_equal "0xec26b0f85ed839ece5f11c4c4e837ec359f5adc4420410f6453b1f6b60fb96a6", api.acp_cell_tx_hash
    end
  end

  context "mainnet" do
    should "return mainnet old acp code hash when acp type is old" do
      blockchain_info = { get_blockchain_info: { chain: "ckb" } }
      api_obj = JSON.parse(blockchain_info.to_json, object_class: OpenStruct)
      CKB::API.stubs(:new).returns(api_obj)
      api = SdkApi.clone.instance
      api.acp_type = "old"
      assert_equal "0x0fb343953ee78c9986b091defb6252154e0bb51044fd2879fde5b27314506111", api.acp_code_hash
    end

    should "return mainnet old acp hash type when acp type is old" do
      blockchain_info = { get_blockchain_info: { chain: "ckb" } }
      api_obj = JSON.parse(blockchain_info.to_json, object_class: OpenStruct)
      CKB::API.stubs(:new).returns(api_obj)
      api = SdkApi.clone.instance
      api.acp_type = "old"
      assert_equal "data", api.acp_hash_type
    end

    should "return mainnet old acp cell tx hash when acp type is old" do
      blockchain_info = { get_blockchain_info: { chain: "ckb" } }
      api_obj = JSON.parse(blockchain_info.to_json, object_class: OpenStruct)
      CKB::API.stubs(:new).returns(api_obj)
      api = SdkApi.clone.instance
      api.acp_type = "old"
      assert_equal "0xa05f28c9b867f8c5682039c10d8e864cf661685252aa74a008d255c33813bb81", api.acp_cell_tx_hash
    end

    should "return mainnet new acp code hash when acp type is new" do
      blockchain_info = { get_blockchain_info: { chain: "ckb" } }
      api_obj = JSON.parse(blockchain_info.to_json, object_class: OpenStruct)
      CKB::API.stubs(:new).returns(api_obj)
      api = SdkApi.clone.instance
      assert_equal "0xd369597ff47f29fbc0d47d2e3775370d1250b85140c670e4718af712983a2354", api.acp_code_hash
    end

    should "return mainnet new acp hash type when acp type is new" do
      blockchain_info = { get_blockchain_info: { chain: "ckb" } }
      api_obj = JSON.parse(blockchain_info.to_json, object_class: OpenStruct)
      CKB::API.stubs(:new).returns(api_obj)
      api = SdkApi.clone.instance
      assert_equal "type", api.acp_hash_type
    end

    should "return mainnet new acp cell tx hash when acp type is new" do
      blockchain_info = { get_blockchain_info: { chain: "ckb" } }
      api_obj = JSON.parse(blockchain_info.to_json, object_class: OpenStruct)
      CKB::API.stubs(:new).returns(api_obj)
      api = SdkApi.clone.instance
      assert_equal "0x4153a2014952d7cac45f285ce9a7c5c0c0e1b21f2d378b82ac1433cb11c25c4d", api.acp_cell_tx_hash
    end
  end
end
