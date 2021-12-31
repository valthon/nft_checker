# frozen_string_literal: true

require "httparty"
require_relative "errors"

module NftChecker
  ###
  # NFT Checker implementation for OpenSea
  class OpenSea
    # @param testnet Use OpenSea 'testnets' API (default false)
    def initialize(testnet: false)
      @url_base = testnet ? "https://testnets-api.opensea.io/" : "https://api.opensea.io/"
    end

    # Verify that the NFT is owned by the given address
    # @param address - address of presumed NFT owner
    # @param nft_metadata - hash containing :contract_address and :token_id values
    def owner?(address, nft_metadata)
      !fetch_nft_for_owner(address, nft_metadata).nil?
    end

    # Verify that the NFT is part of the referenced collection
    # @param collection_metadata - hash containing :slug for OpenSea collection
    # @param nft_metadata - hash containing :contract_address and :token_id values
    def in_collection?(collection_metadata, nft_metadata)
      nft = fetch_nft(nft_metadata)
      return false if nft.nil?

      collection_metadata.each_key do |key|
        return false unless nft["collection"][key.to_s].casecmp(collection_metadata[key]).zero?
      end
      true
    end

    # [Deprecated] Verify that the NFT is owned by the given address
    # @param nft_metadata - hash containing :contract_address and :token_id values
    # @param owner_address - address of presumed NFT owner
    def verify_owner(nft_metadata, owner_address)
      owner?(owner_address, nft_metadata)
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

    def fetch_nft(nft_metadata)
      contract, token = nft_metadata.slice(:contract_address, :token_id).values
      rez = HTTParty.get(@url_base + "asset/#{contract}/#{token}/")
      handle_response_codes(rez, not_found: nil) do
        rez.parsed_response
      end
    end

    def fetch_nft_for_owner(owner_address, nft_metadata)
      contract, token = nft_metadata.slice(:contract_address, :token_id).values
      rez = HTTParty.get(@url_base + "asset/#{contract}/#{token}/", query: { account_address: owner_address })
      handle_response_codes(rez, not_found: nil) do
        data = rez.parsed_response
        data if data["ownership"] &&
                data["ownership"]["owner"]["address"].casecmp(owner_address).zero? &&
                data["ownership"]["quantity"].to_i.positive?
      end
    end

    def handle_response_codes(rez, not_found: nil)
      case rez.code
      when 429
        raise Throttled
      when 404
        not_found
      when 200
        yield
      else
        raise Error, rez.to_s
      end
    end
  end
end
