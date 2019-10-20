module Fastlane
  module Actions
    require 'fastlane/plugin/google_drive/actions/upload_to_google_drive_action'
    class UploadGoogleDriveAction < UploadToGoogleDriveAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `upload_to_google_drive` action"
      end

      def self.category
        :deprecated
      end

      def self.deprecated_notes
        [
          "Please use `upload_to_google_drive` instead."
        ].join("\n")
      end
    end
  end
end
