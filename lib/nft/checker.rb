# frozen_string_literal: true

require_relative "checker/version"
require_relative "checker/source/open_sea"

module Nft
  ###
  # Nft::Checker is a tool for verifying NFT ownership
  #
  # Use the `init` method to generate a checker for a given NFT source
  # Currently supported sources:
  # * OpenSea
  #
  # Checkers all support the following methods:
  # * verify_owner(nft_metadata, owner_address): boolean
  # * list_nfts(collection_metadata, owner_address): [<NFT ID>,...]
  module Checker
    class Error < StandardError; end

    def self.init(source, options = {})
      case source
      when :opensea
        Source::OpenSea.new(testnet: options[:testnet])
      else
        raise "Unknown source: #{source}"
      end
    end
  end
end
