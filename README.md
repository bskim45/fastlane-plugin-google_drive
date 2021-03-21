# google_drive `fastlane` plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-google_drive)
[![Gem Version Badge](https://badge.fury.io/rb/fastlane-plugin-google_drive.svg)](https://badge.fury.io/rb/fastlane-plugin-google_drive)
[![Build Status](https://travis-ci.com/bskim45/fastlane-plugin-google_drive.svg?branch=master)](https://travis-ci.com/bskim45/fastlane-plugin-google_drive)
[![Test Coverage](https://api.codeclimate.com/v1/badges/681ab1f5c19ca029dff4/test_coverage)](https://codeclimate.com/github/bskim45/fastlane-plugin-google_drive/test_coverage)
[![security](https://hakiri.io/github/bskim45/fastlane-plugin-google_drive/master.svg)](https://hakiri.io/github/bskim45/fastlane-plugin-google_drive/master)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-google_drive`, add it to your project by running:

```bash
fastlane add_plugin google_drive
```

## About google_drive

> Please refer to [this guide](https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md) to create an Google Drive credential.

Upload files to Google Drive folder.
> Aliases for this action - `google_drive_upload` and `upload_google_drive` are both removed in `v0.6.0`.

```ruby
upload_to_google_drive(
  drive_keyfile: 'drive_key.json',
  service_account: true,
  folder_id: 'folder_id',
  upload_files: ['file_to_upload', 'another_file_to_upload']
)
```

Create new Google Drive folder:

```ruby
create_google_drive_folder(
  drive_keyfile: 'drive_key.json',
  folder_id: '#{folder_id}',
  folder_title: 'new_folder'
)
```

Update the content of existing Google Drive file:

```ruby
update_google_drive_file(
  drive_keyfile: 'drive_key.json',
  file_id: 'file_id',
  upload_file: 'path/to/file.txt'
)
```

Download feature is not implemented yet. PR is always welcome.

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

## Run tests for this plugin

To run both the tests, and code style validation, run

```bash
rake
```

To automatically fix many of the styling issues, use

```bash
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

## License

The MIT License (MIT)

Copyright (c) 2019 Bumsoo Kim (<https://bsk.im>)
