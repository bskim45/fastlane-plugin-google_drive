require 'dotenv/load'

describe Fastlane::Actions::CreateGoogleDriveFolderAction do
  before(:context) do
    @key_path = File.join(File.dirname(File.dirname(__FILE__)), 'drive_key.json')
    raise("specify upload test folder id") unless ENV['TEST_UPLOAD_FOLDER_ID'] and !ENV['TEST_UPLOAD_FOLDER_ID'].empty?
    raise("drive key json file does not exists") unless File.exist?(@key_path)
  end

  before(:each) do
    ENV['GDRIVE_SERVICE_ACCOUNT'] = ENV['TEST_SERVICE_ACCOUNT']
  end

  after(:each) do
    ENV.delete('GDRIVE_SERVICE_ACCOUNT')
  end

  context 'when creating is failed' do
    it 'raise an error if keyfile does not exists' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
        create_google_drive_folder(drive_keyfile: 'test.json')
      end").runner.execute(:test)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "Couldn't find config keyfile at path 'test.json'")
    end

    it 'raise an error if no folder_id was given' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
        create_google_drive_folder(drive_keyfile: '#{@key_path}')
      end").runner.execute(:test)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "No target folder_id given, pass using `folder_id: 'some_id'`")
    end

    it 'raise an error if no folder_title was given' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
        create_google_drive_folder(drive_keyfile: '#{@key_path}', folder_id: 'some_id', folder_title: '')
      end").runner.execute(:test)
      end.to raise_error(FastlaneCore::Interface::FastlaneError)
    end

    it "raise an error if folder_id does not exist" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
        create_google_drive_folder(drive_keyfile: '#{@key_path}', folder_id: 'some_id', folder_title: 'new_folder')
      end").runner.execute(:test)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "File with id 'some_id' not found in Google Drive")
    end

    it "raise an error if creating folder fails" do
      allow_any_instance_of(GoogleDrive::Collection).to receive(:create_subcollection).and_raise(Exception.new('something went wrong'))
      folder_id = ENV['TEST_UPLOAD_FOLDER_ID']

      expect do
        Fastlane::FastFile.new.parse("lane :test do
      create_google_drive_folder(drive_keyfile: '#{@key_path}', folder_id: '#{folder_id}', folder_title: 'new_folder')
    end").runner.execute(:test)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "Create 'new_folder' failed")
    end
  end

  context 'when creating is succeeded' do
    let(:new_folder) { double('GoogleDrive::Collection') }
    before do
      allow_any_instance_of(GoogleDrive::Collection).to receive(:create_subcollection).and_return(new_folder)
      allow(new_folder).to receive(:resource_id).and_return('folder:abcdefg')
      allow(new_folder).to receive(:human_url).and_return('https://example.com/abcdefg')
    end

    it 'set lane_context if creating folder is succeeded' do
      expect_any_instance_of(GoogleDrive::Collection).to receive(:create_subcollection).with('new_folder')

      folder_id = ENV['TEST_UPLOAD_FOLDER_ID']
      Fastlane::FastFile.new.parse("lane :test do
      create_google_drive_folder(drive_keyfile: '#{@key_path}', folder_id: '#{folder_id}', folder_title: 'new_folder')
    end").runner.execute(:test)

      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_CREATED_FOLDER_ID]).to eq('abcdefg')
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_CREATED_FOLDER_URL]).to eq('https://example.com/abcdefg')
    end
  end
end
