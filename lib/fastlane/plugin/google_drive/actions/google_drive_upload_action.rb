module Fastlane
  module Actions
    require 'fastlane/plugin/google_drive/actions/upload_to_google_drive_action'
    class GoogleDriveUploadAction < UploadToGoogleDriveAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `upload_to_google_drive` action"
      end
    end
  end
end
