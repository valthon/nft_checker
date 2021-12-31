# frozen_string_literal: true

TEST_COLLECTION = { slug: "untitled-collection-4919696" }.freeze
TEST_NFT = {
  contract_address: "0x88B48F654c30e99bc2e4A1559b4Dcf1aD93FA656",
  token_id: "2311777711455776243141183398852532457844153089003796399814364866449093165057"
}.freeze
ALT_NFT = {
  contract_address: "0xcc14dd8e6673fee203366115d3f9240b079a4930",
  token_id: "1147"
}.freeze
FAKE_NFT = {
  contract_address: "0x88B48F654c30e99bc2e4A1559b4Dcf1aD93FA656",
  token_id: "99231177771145577624314118339885253245784415308900379639981436486644909316505799"
}.freeze
ALL_MY_NFT_IDS = %w[
  2311777711455776243141183398852532457844153089003796399814364866449093165057
  2311777711455776243141183398852532457844153089003796399814364869747628048385
  2311777711455776243141183398852532457844153089003796399814364868648116420609
  2311777711455776243141183398852532457844153089003796399814364867548604792833
].freeze

TEST_ETH_WALLET = "0x051c6B791044102Ae773e27FEA21480ed6D653F4"
ALT_ETH_WALLET  = "0x052c6B491044102Ae373e27FEA21380ed6D6A3F4"

RSpec.describe NftChecker do
  it "has a version number" do
    expect(NftChecker::VERSION).not_to be nil
  end

  context "on OpenSea", :vcr do
    subject(:checker) { NftChecker.init(:opensea, testnet: true) }

    describe "#owner?" do
      it "discovers owner of nft on opensea" do
        expect(checker.owner?(TEST_ETH_WALLET, TEST_NFT)).to eq(true)
      end

      it "does not mis-attribute ownership" do
        expect(checker.owner?(ALT_ETH_WALLET, TEST_NFT)).to eq(false)
      end
    end

    describe "#verify_owner" do
      it "discovers owner of nft on opensea" do
        expect(checker.verify_owner(TEST_NFT, TEST_ETH_WALLET)).to eq(true)
      end

      it "does not mis-attribute ownership" do
        expect(checker.verify_owner(TEST_NFT, ALT_ETH_WALLET)).to eq(false)
      end
    end

    describe "#list_nfts" do
      it "lists all nfts owned by the address" do
        nfts = checker.list_nfts(TEST_COLLECTION, TEST_ETH_WALLET)
        nft_ids = nfts.map { |nft| nft["token_id"] }
        expect(nft_ids).to contain_exactly(*ALL_MY_NFT_IDS)
      end

      it "does not list unowned nfts" do
        expect(checker.list_nfts(TEST_COLLECTION, ALT_ETH_WALLET)).to eq([])
      end
    end

    describe "#in_collection?" do
      it "returns true for the test NFT" do
        expect(checker.in_collection?(TEST_COLLECTION, TEST_NFT)).to be_truthy
      end

      it "returns false for a different NFT" do
        expect(checker.in_collection?(TEST_COLLECTION, ALT_NFT)).to be_falsey
      end

      it "returns false for a non-existent NFT" do
        expect(checker.in_collection?(TEST_COLLECTION, FAKE_NFT)).to be_falsey
      end
    end
  end
end
