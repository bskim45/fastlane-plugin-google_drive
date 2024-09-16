require 'fastlane/action'
require_relative '../helper/google_drive_helper'

module Fastlane
  module Actions
    module SharedValues
      GDRIVE_FILE_ID = :GDRIVE_FILE_ID
      GDRIVE_FILE_TITLE = :GDRIVE_FILE_TITLE
      GDRIVE_FILE_URL = :GDRIVE_FILE_URL
    end

    class FindGoogleDriveFileByIdAction < Action
      def self.run(params)
        unless params[:drive_keyfile].nil?
          UI.message("Using credential file: #{params[:drive_keyfile]}")
        end

        session = Helper::GoogleDriveHelper.setup(
          keyfile: params[:drive_keyfile],
          key_json: params[:drive_key_json],
          service_account: params[:service_account]
        )

        # parameter validation
        target_file_id = params[:file_id]

        begin
          file = Helper::GoogleDriveHelper.file_by_id(
            session: session, fid: target_file_id
          )
        rescue FastlaneCore::Interface::FastlaneError
          file = nil
        end

        if file.nil?
          UI.error("No file or folder was found.")
        else
          Actions.lane_context[SharedValues::GDRIVE_FILE_ID] = file.resource_id.split(':').last
          Actions.lane_context[SharedValues::GDRIVE_FILE_TITLE] = file.title
          Actions.lane_context[SharedValues::GDRIVE_FILE_URL] = file.human_url
        end
      end

      def self.description
        'Find a Google Drive file or folder by ID'
      end

      def self.details
        [
          'Find a Google Drive file or folder by ID',
          'See https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md to get a keyfile'
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :drive_keyfile,
            env_names: ['GDRIVE_KEY_FILE', 'GOOGLE_APPLICATION_CREDENTIALS'],
            description: 'Path to the JSON keyfile',
            conflicting_options: [:drive_key_json],
            type: String,
            optional: true,
            verify_block: proc do |value|
              UI.user_error!("Couldn't find config keyfile at path '#{value}'") unless File.exist?(value)
              UI.user_error!("'#{value}' doesn't seem to be a valid JSON keyfile") unless FastlaneCore::Helper.json_file?(value)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :drive_key_json,
            env_name: 'GDRIVE_KEY_JSON',
            description: 'Credential key in stringified JSON format',
            optional: true,
            conflicting_options: [:drive_keyfile],
            type: String,
            sensitive: true,
            verify_block: proc do |value|
              begin
                JSON.parse(value)
              rescue JSON::ParserError
                UI.user_error!("Provided credential key is not a valid JSON")
              end
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :service_account,
            env_name: 'GDRIVE_SERVICE_ACCOUNT',
            description: 'true if the credential is for a service account, false otherwise',
            optional: true,
            is_string: false,
            default_value: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :file_id,
            env_name: 'GDRIVE_TARGET_FILE_ID',
            description: 'Target file or folder ID to check the existence',
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("No `file_id` was given. Pass it using `file_id: 'some_id'`") if value.nil? || value.empty?
            end
          )
        ]
      end

      def self.output
        [
          ['GDRIVE_FILE_ID', 'The file ID of the file or folder.'],
          ['GDRIVE_FILE_TITLE', 'The title of the file or folder.'],
          ['GDRIVE_FILE_URL', 'The link to the file or folder.']
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
