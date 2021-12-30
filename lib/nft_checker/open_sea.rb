# frozen_string_literal: true

require "httparty"
module NftChecker
  ###
  # NFT Checker implementation for OpenSea
  class OpenSea
    # @param testnet Use OpenSea 'testnets' API (default false)
    def initialize(testnet: false)
      @url_base = testnet ? "https://testnets-api.opensea.io/" : "https://api.opensea.io/"
    end

    # Verify that the NFT is owned by the given address
    # @param nft_metadata - hash containing :contract_address and :token_id values
    # @param owner_address - address of presumed NFT owner
    def verify_owner(nft_metadata, owner_address)
      contract, token = nft_metadata.slice(:contract_address, :token_id).values
      rez = HTTParty.get(@url_base + "asset/#{contract}/#{token}/", query: { account_address: owner_address })
      handle_response_codes(rez, not_found: false) do
        ownership_data = rez.parsed_response["ownership"]
        return false if ownership_data.nil?

        ownership_data["owner"]["address"].casecmp(owner_address).zero? && ownership_data["quantity"].to_i.positive?
      end
    end

    # List all NFTs in the collection owned by the given address
    # @param collection_metadata - hash containing :slug for OpenSea collection
    # @param owner_address - address to check for NFTs
    def list_nfts(collection_metadata, owner_address)
      rez = HTTParty.get("#{@url_base}assets", query: { owner: owner_address, collection: collection_metadata[:slug] })
      handle_response_codes(rez, not_found: []) do
        rez.parsed_response["assets"] || []
      end
    end

    private

    def handle_response_codes(rez, not_found: nil)
      case rez.code
      when 429
        raise Throttled
      when 400
        not_found
      when 200
        yield
      else
        raise Error(rez.to_s)
      end
    end
  end
end
