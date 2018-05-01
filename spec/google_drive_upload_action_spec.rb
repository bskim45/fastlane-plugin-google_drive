require 'spec_helper'

describe Fastlane::Actions::GoogleDriveUploadAction do
  before do
    allow(Fastlane::Actions::UploadToGoogleDriveAction).to receive(:run)
    allow(File).to receive(:exist?).and_return(true)
  end

  context 'when calling google_drive_upload_action' do
    it 'called upload_google_drive_action instead' do
      expect(Fastlane::Actions::UploadToGoogleDriveAction).to receive(:run)
      Fastlane::FastFile.new.parse("lane :test do
        google_drive_upload
      end").runner.execute(:test)
    end
  end
end