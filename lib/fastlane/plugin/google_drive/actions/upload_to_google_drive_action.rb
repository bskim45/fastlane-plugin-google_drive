require 'fastlane/action'
require_relative '../helper/google_drive_helper'

module Fastlane
  module Actions
    module SharedValues
      GDRIVE_UPLOADED_FILE_NAMES = :GDRIVE_UPLOADED_FILE_NAMES
      GDRIVE_UPLOADED_FILE_URLS = :GDRIVE_UPLOADED_FILE_URLS
    end

    class UploadToGoogleDriveAction < Action
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

        uploaded_files = []
        assets = params[:upload_files]
        generate_public_links = params[:public_links]

        UI.abort_with_message!("No files to upload") if assets.nil? or assets.empty?

        assets.each do |asset|
          UI.message('------------------')
          UI.important("Uploading #{asset}")
          uploaded_files.push(Helper::GoogleDriveHelper.upload_file(file: folder, file_name: asset))
          UI.success('Success')
          UI.message('------------------')
        end

        Actions.lane_context[SharedValues::GDRIVE_UPLOADED_FILE_NAMES] = uploaded_files.map(&:title)
        Actions.lane_context[SharedValues::GDRIVE_UPLOADED_FILE_URLS] =
          if generate_public_links
            uploaded_files.map(&Helper::GoogleDriveHelper.method(:create_public_url))
          else
            uploaded_files.map(&:human_url)
          end
      end

      def self.description
        'Upload files to Google Drive'
      end

      def self.details
        [
          'Upload files to Google Drive',
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
            key: :upload_files,
            env_name: "GDRIVE_UPLOAD_FILES",
            description: "Path to files to be uploaded",
            optional: false,
            is_string: false,
            verify_block: proc do |value|
              UI.user_error!("upload_files must be an Array of paths to files") unless value.kind_of?(Array)
              UI.user_error!("No upload file is given, pass using `upload_files: ['a', 'b']`") unless value and !value.empty?
              value.each do |path|
                UI.user_error!("Couldn't find upload file at path '#{path}'") unless File.exist?(path)
              end
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :public_links,
            env_name: 'GDRIVE_PUBLIC_LINKS',
            description: 'Uploaded file links should be public',
            optional: true,
            default_value: false,
            is_string: false
          )
        ]
      end

      def self.output
        [
          ['GDRIVE_UPLOADED_FILE_NAMES', 'The array of names of uploaded files'],
          ['GDRIVE_UPLOADED_FILE_URLS', 'The array of links to uploaded files']
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
