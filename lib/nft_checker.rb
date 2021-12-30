# frozen_string_literal: true

require_relative "nft_checker/version"
require_relative "nft_checker/open_sea"

###
# NftChecker is a tool for verifying NFT ownership
#
# Use the `init` method to generate a checker for a given NFT source
# Currently supported sources:
# * OpenSea
#
# Checkers all support the following methods:
# * verify_owner(nft_metadata, owner_address): boolean
# * list_nfts(collection_metadata, owner_address): [<NFT ID>,...]
#
module NftChecker
  class Error < StandardError; end
  class Throttled < Error; end

  def self.init(source, options = {})
    case source.to_s
    when /\Aopen\w?sea(.io)?\z/i
      OpenSea.new(testnet: options[:testnet])
    else
      raise "Unknown source: #{source}"
    end
  end
end
