# frozen_string_literal: true

TEST_COLLECTION = { slug: "untitled-collection-4919696" }.freeze
TEST_NFT = {
  contract_address: "0x88B48F654c30e99bc2e4A1559b4Dcf1aD93FA656",
  token_id: "2311777711455776243141183398852532457844153089003796399814364866449093165057"
}.freeze

TEST_ETH_WALLET = "0x051c6B791044102Ae773e27FEA21480ed6D653F4"
ALT_ETH_WALLET  = "0x052c6B491044102Ae373e27FEA21380ed6D6A3F4"

RSpec.describe Nft::Checker do
  it "has a version number" do
    expect(Nft::Checker::VERSION).not_to be nil
  end

  context "on OpenSea", :vcr do
    subject(:checker) { Nft::Checker.init(:opensea, testnet: true) }
    it "discovers owner of nft on opensea" do
      expect(checker.verify_owner(TEST_NFT, TEST_ETH_WALLET)).to eq(true)
    end

    it "does not mis-attribute ownership" do
      expect(checker.verify_owner(TEST_NFT, ALT_ETH_WALLET)).to eq(false)
    end

    it "lists all nfts owned by the address" do
      expect(checker.list_nfts(TEST_COLLECTION, TEST_ETH_WALLET).first["token_id"]).to eq(TEST_NFT[:token_id])
      expect(checker.list_nfts(TEST_COLLECTION,
                               TEST_ETH_WALLET)).to contain_exactly(include("token_id" => TEST_NFT[:token_id]))
    end

    it "does not list unowned nfts" do
      expect(checker.list_nfts(TEST_COLLECTION, ALT_ETH_WALLET)).to eq([])
    end
  end
end

# curl --request GET \
#      --url 'https://testnets-api.opensea.io/assets?owner=0x051c6B791044102Ae773e27FEA21480ed6D653F4&order_direction=desc&offset=0&limit=20&collection=untitled-collection-4919696'
#
#
