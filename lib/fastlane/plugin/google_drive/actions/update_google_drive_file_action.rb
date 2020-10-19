require 'fastlane/action'
require_relative '../helper/google_drive_helper'

module Fastlane
  module Actions
    module SharedValues
      GDRIVE_UPDATED_FILE_NAME = :GDRIVE_UPDATED_FILE_NAME
      GDRIVE_UPDATED_FILE_URL = :GDRIVE_UPDATED_FILE_URL
    end
    class UpdateGoogleDriveFileAction < Action
      def self.run(params)
        UI.message("Using config file: #{params[:drive_keyfile]}")

        session = Helper::GoogleDriveHelper.setup(
          keyfile: params[:drive_keyfile],
          service_account: params[:service_account]
        )

        file = Helper::GoogleDriveHelper.file_by_id(
          session: session, fid: params[:file_id]
        )

        upload_file = params[:upload_file]
        UI.abort_with_message!("No file to upload") if upload_file.nil? or upload_file.empty?

        UI.message('------------------')
        UI.important("Uploading #{upload_file}")
        Helper::GoogleDriveHelper.update_file(file: file, file_name: upload_file)
        UI.success('Success')
        UI.message('------------------')

        Actions.lane_context[SharedValues::GDRIVE_UPDATED_FILE_NAME] = file.title
        Actions.lane_context[SharedValues::GDRIVE_UPDATED_FILE_URL] = file.human_url
      end

      def self.description
        'Update a Google Drive file'
      end

      def self.details
        [
          'Update a Google Drive file',
          'See https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md to get a keyfile'
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :drive_keyfile,
                                      env_name: 'GDRIVE_KEY_FILE',
                                      description: 'Json config file',
                                      type: String,
                                      default_value: 'drive_key.json',
                                      verify_block: proc do |value|
                                        UI.user_error!("Couldn't find config keyfile at path '#{value}'") unless File.exist?(value)
                                      end),
          FastlaneCore::ConfigItem.new(key: :service_account,
                                      env_name: 'GDRIVE_SERVICE_ACCOUNT',
                                      description: 'Credential is service account',
                                      optional: true,
                                      is_string: false,
                                      default_value: false),
          FastlaneCore::ConfigItem.new(key: :file_id,
                                      env_name: "GDRIVE_UPDATE_FILE_ID",
                                      description: "Target file id to update the content",
                                      optional: false,
                                      type: String,
                                      verify_block: proc do |value|
                                        UI.user_error!("No target file id given, pass using `file_id: 'some_id'`") unless value and !value.empty?
                                      end),
          FastlaneCore::ConfigItem.new(key: :upload_file,
                                      env_name: "GDRIVE_UPLOAD_FILE",
                                      description: "Path to a file to be uploaded",
                                      optional: false,
                                      is_string: false,
                                      verify_block: proc do |value|
                                        UI.user_error!("No upload file is given, pass using `upload_file: 'some/path/a.txt'`") unless value and !value.empty?
                                        UI.user_error!("Couldn't find upload file at path '#{value}'") unless File.exist?(value)
                                      end)
        ]
      end

      def self.output
        [
          ['GDRIVE_UPDATED_FILE_NAME', 'The name of the uploaded file'],
          ['GDRIVE_UPDATED_FILE_URL', 'The link to the uploaded file']
        ]
      end

      def self.return_value
        # nothing
      end

      def self.authors
        ['Bumsoo Kim (@bskim45)']
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
