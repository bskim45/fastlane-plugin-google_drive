# google_drive `fastlane` plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-google_drive)
[![Gem Version Badge](https://badge.fury.io/rb/fastlane-plugin-google_drive.svg)](https://badge.fury.io/rb/fastlane-plugin-google_drive)
[![Build Status](https://travis-ci.org/bskim45/fastlane-plugin-google_drive.svg?branch=master)](https://travis-ci.org/bskim45/fastlane-plugin-google_drive)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-google_drive`, add it to your project by running:

```bash
fastlane add_plugin google_drive
```

## About google_drive

```ruby
upload_to_google_drive(
  drive_keyfile: 'drive_key.json',
  service_account: true,
  folder_id: 'folder_id',
  upload_files: ['file_to_upload', 'another_file_to_upload']
)
```

Upload files to Google Drive folder.
You can also use `google_drive_upload` or `upload_google_drive` as aliases.

```ruby
create_google_drive_folder(
  drive_keyfile: 'drive_key.json',
  folder_id: '#{folder_id}',
  folder_title: 'new_folder'
)
```

Create new Google Drive folder

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

Copyright (c) 2018 Bumsoo Kim (<https://bsk.im>)
