# frozen_string_literal: true

require "httparty"
module Nft
  module Checker
    module Source
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
          clean_address = owner_address.downcase
          contract, token = nft_metadata.slice(:contract_address, :token_id).values
          rez = HTTParty.get(@url_base + "asset/#{contract}/#{token}/", query: { account_address: clean_address })
          ownership_data = rez.parsed_response["ownership"]
          ownership_data["owner"]["address"].downcase == clean_address && ownership_data["quantity"].to_i >= 1
        rescue StandardError
          false
        end

        # List all NFTs in the collection owned by the given address
        # @param collection_metadata - hash containing :slug for OpenSea collection
        # @param owner_address - address to check for NFTs
        def list_nfts(collection_metadata, owner_address)
          clean_address = owner_address.downcase
          slug = collection_metadata[:slug]
          rez = HTTParty.get("#{@url_base}assets", query: { owner: clean_address, collection: slug })
          rez.parsed_response["assets"] || []
        rescue StandardError
          []
        end
      end
    end
  end
end
