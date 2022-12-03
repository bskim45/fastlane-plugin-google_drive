require 'fastlane/action'
require_relative '../helper/google_drive_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class FindGoogleDriveFileByTitleAction < Action
      def self.run(params)
        UI.message("Using credential file: #{params[:drive_keyfile]}")

        session = Helper::GoogleDriveHelper.setup(
          keyfile: params[:drive_keyfile],
          service_account: params[:service_account]
        )

        # parameter validation
        parent_folder_id = params[:parent_folder_id]
        file_title = params[:file_title]

        parent_folder = Helper::GoogleDriveHelper.file_by_id(
          session: session, fid: parent_folder_id
        )

        UI.abort_with_message!('The parent folder was not found.') if parent_folder.nil?

        begin
          file = Helper::GoogleDriveHelper.file_by_title(
            root_folder: parent_folder, title: file_title
          )
        rescue FastlaneCore::Interface::FastlaneError
          file = nil
        end

        if file.nil?
          UI.error('No file or folder was found.')
        else
          Actions.lane_context[SharedValues::GDRIVE_FILE_ID] = file.resource_id.split(':').last
          Actions.lane_context[SharedValues::GDRIVE_FILE_TITLE] = file.title
          Actions.lane_context[SharedValues::GDRIVE_FILE_URL] = file.human_url
        end
      end

      def self.description
        'Find a Google Drive file or folder by title'
      end

      def self.details
        [
          'Find a Google Drive file or folder by title',
          'See https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md to get a keyfile'
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :drive_keyfile,
            env_name: 'GDRIVE_KEY_FILE',
            description: 'The path to the json keyfile',
            type: String,
            default_value: 'drive_key.json',
            verify_block: proc do |value|
              UI.user_error!("Couldn't find config keyfile at path '#{value}'") unless File.exist?(value)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :service_account,
            env_name: 'GDRIVE_SERVICE_ACCOUNT',
            description: 'Whether the credential file is for the google service account',
            optional: true,
            is_string: false,
            default_value: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :parent_folder_id,
            env_name: 'GDRIVE_PARENT_FOLDER_ID',
            description: 'The parent folder ID of the target file or folder to check the existence',
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("No `parent_folder_id` was given. Pass it using `parent_folder_id: 'some_id'`") unless value and !value.empty?
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :file_title,
            env_name: 'GDRIVE_TARGET_FILE_TITLE',
            description: 'Target file or folder title to check the existence',
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("No `file_title` was given. Pass it using `file_title: 'some_title'`") unless value and !value.empty?
            end
          ),
        ]
      end

      def self.output
        [
          ['GDRIVE_FILE_ID', 'The file title of the file or folder'],
          ['GDRIVE_FILE_TITLE', 'The title of the file or folder'],
          ['GDRIVE_FILE_URL', 'The link to the file or folder']
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
