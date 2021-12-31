# frozen_string_literal: true

module NftChecker
  class Error < StandardError; end
  class Throttled < Error; end
end
