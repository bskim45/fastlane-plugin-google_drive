require 'spec_helper'

describe Fastlane::Actions::UploadGoogleDriveAction do
  before do
    allow(Fastlane::Actions::UploadToGoogleDriveAction).to receive(:run)
    allow(File).to receive(:exist?).and_return(true)
  end

  context 'when calling upload_google_drive_action' do
    it 'called upload_to_google_drive_action instead' do
      expect(Fastlane::Actions::UploadToGoogleDriveAction).to receive(:run)
      Fastlane::FastFile.new.parse("lane :test do
        google_drive_upload
      end").runner.execute(:test)
    end
  end
end