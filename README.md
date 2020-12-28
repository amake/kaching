# Kaching

A simple tool to check the latest sales numbers for apps on the Apple App Store
or Google Play.

## Installation

1. Clone this repo
2. Copy the [example config](./config.json.example) to `config.json` and fill it
   in. If you haven't already, setup access and download keys/auth files for:
   - [App Store Connect API](https://developer.apple.com/app-store-connect/api/)
   - [Google Developers Console](https://support.google.com/googleplay/android-developer/answer/6135870#export)
     service account

## Usage

Run `bin/kaching` to announce the latest sales count (macOS only).

Optionally set up an entry in [SwiftBar](https://swiftbar.app/): symlink
`bin/kaching-swiftbar` to your SwiftBar plugins folder with the filename `<app
name>.<interval>.rb`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/amake/kaching.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
