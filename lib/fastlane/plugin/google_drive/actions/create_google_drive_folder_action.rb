require 'fastlane/action'
require_relative '../helper/google_drive_helper'

module Fastlane
  module Actions
    module SharedValues
      GDRIVE_CREATED_FOLDER_ID = :GDRIVE_CREATED_FOLDER_ID
      GDRIVE_CREATED_FOLDER_URL = :GDRIVE_CREATED_FOLDER_URL
    end

    class CreateGoogleDriveFolderAction < Action
      def self.run(params)
        unless params[:drive_keyfile].nil?
          UI.message("Using credential file: #{params[:drive_keyfile]}")
        end

        session = Helper::GoogleDriveHelper.setup(
          keyfile: params[:drive_keyfile],
          key_json: params[:drive_key_json],
          service_account: params[:service_account]
        )

        folder = Helper::GoogleDriveHelper.file_by_id(
          session: session, fid: params[:folder_id]
        )

        title = params[:folder_title]
        UI.message('------------------')
        UI.important("Creating #{title}")
        new_folder = Helper::GoogleDriveHelper.create_subcollection(root_folder: folder, title: title)
        UI.success('Success')
        UI.message('------------------')

        folder_id = new_folder.resource_id.split(':').last
        Actions.lane_context[SharedValues::GDRIVE_CREATED_FOLDER_ID] = folder_id
        Actions.lane_context[SharedValues::GDRIVE_CREATED_FOLDER_URL] = new_folder.human_url

        new_folder
      end

      def self.description
        'Create new folder on Google Drive'
      end

      def self.details
        [
          'Create new folder on Google Drive',
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
            key: :folder_id,
            env_name: "GDRIVE_UPLOAD_FOLDER_ID",
            description: "Upload target folder id",
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("No target `folder_id` was provided. Pass it using `folder_id: 'some_id'`") unless value and !value.empty?
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :folder_title,
            env_name: "GDRIVE_FOLDER_NAME",
            description: "Folder title of new one",
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("No folder title given") if value.nil? || value.empty?
            end
          )
        ]
      end

      def self.output
        [
          ['GDRIVE_CREATED_FOLDER_ID', 'ID of the created folder'],
          ['GDRIVE_CREATED_FOLDER_URL', 'Link to the created folder']
        ]
      end

      def self.return_value
        '`GoogleDrive::Collection` object which indicates the created folder.'
      end

      def self.authors
        ['Bumsoo Kim (@bskim45)', 'Kohki Miki (@giginet)']
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
