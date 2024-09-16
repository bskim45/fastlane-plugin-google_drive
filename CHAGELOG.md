# CHANGELOG


## v0.10.0 (2024-09-16)

### Breaking Changes

The default value of `drive_keyfile` (`drive_key.json`) is removed.
Now, **you must specify the key file path manually** via
the `drive_keyfile` argument or the `GDRIVE_KEY_FILE` environment variable.
This change applies to all actions.

### Changelog
- Added the argument `drive_key_json` (env: `GDRIVE_KEY_JSON`) to all actions,
  allowing you to provide the JSON key file content directly.

- You can also specify the path to the JSON key file using 
  the `GOOGLE_APPLICATION_CREDENTIALS` environment variable,
  commonly used in other SDKs and libraries.

## v0.9.0 (2022-12-03)

### Changelog

- Introduce new actions: `find_google_drive_file_by_id` and `find_google_drive_file_by_title`. 
  These actions find the existing file or folder with file ID or title.
  For more information, please refer to [README](README.md) or [Fastfile](fastlane/Fastfile) for working examples.

## v0.8.0 (2022-09-18)

### Changelog

- switched to [the forked-version of `google_drive`](https://github.com/bskim45/google-drive-ruby)
  to avoid conflict with `google-auth` gem,
  since [the original version of `google_drive`](https://github.com/gimite/google-drive-ruby)
  seems no longer maintained.
  We'll switch back to the original when it's actively maintained again.

## v0.7.0 (2021-07-12)

### Changelog

- upgraded `google_drive` to `3.0.7` use service-specific Google API client (#18, #19).  
  Now we use `google-apis-drive_v3` and `google-apis-sheets_v4` instead of deprecated monolithic `google-api-client` (see https://googleapis.dev/ruby/google-api-client/latest/index.html).

## v0.6.0 (2021-03-21)

### Breaking Changes

- As noticed, deprecated actions `google_drive_upload` and `upload_google_drive` are removed.

### Changelog

- `upload_to_google_drive`: Add optional flag to make uploaded files urls open to public (#17)
- `upload_to_google_drive`: Add test to check generated public urls after upload 
- deprecated actions `google_drive_upload` and `upload_google_drive` are removed

## v0.5.0 (2020-10-20)

### Deprecation Notice

Actions marked as deprecated, `google_drive_upload` and `upload_google_drive` will be removed in next release.

### Breaking Changes

- minimum `fastlane` version is updated to `2.140.0`

### Changelog

- New action: `update_google_drive_file` (#11). This action updates the content of existing google drive file.
- supports "Team Drive" (#9). see gimite/google-drive-ruby#274 and gimite/google-drive-ruby#367 for more details.
- updated `google_drive` to `3.0.5`
- updated `google-api-client` to `0.38.0`
