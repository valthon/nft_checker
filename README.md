# NftChecker

NFT Checker is a utility to verify NFT ownership.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nft_checker'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install nft_checker

## Usage

```ruby
require 'nft_checker'
checker = NftChecker.init(:opensea)
# or, for testnets:
# checker = NftChecker.init(:opensea, testnet: true)

# List all "naturedivas" still owned by AleyArt
list = checker.list_nfts({slug: naturedivas}, "0x422699b0f5891c8ddd306c08d9856032264c5e8e" )
p list.map {|nft| nft["image_url"]} # [ "https://...", ... ]

# Verify that naturediva 016 is still owned by Thision
still_owned = checker.owner?(
  "0x3dec7052aa8d55b3b6b6ad2c6bce195a9acca404",
  {
    contract_address: "0x495f947276749Ce646f68AC8c248420045cb7b5e",
    token_id: "29920848932956748486580529385461081269564523998318357035541486687674930561025"
  }
)
p still_owned # true

# Verify that naturediva 016 is part of the naturediva collection
verified = checker.in_collection?(
  {slug: naturedivas},
  {
    contract_address: "0x495f947276749Ce646f68AC8c248420045cb7b5e",
    token_id: "29920848932956748486580529385461081269564523998318357035541486687674930561025"
  }
)
p verified # true

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/valthon/nft_checker.
