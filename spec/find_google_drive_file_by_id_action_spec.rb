require 'dotenv/load'

describe Fastlane::Actions::FindGoogleDriveFileByIdAction do
  before(:context) do
    @key_path = File.join(File.dirname(File.dirname(__FILE__)), 'drive_key.json')
    @test_existence_file_id = ENV['TEST_CHECK_EXISTENCE_FILE_ID']
    @test_existence_folder_id = ENV['TEST_CHECK_EXISTENCE_FOLDER_ID']
    ENV['GDRIVE_SERVICE_ACCOUNT'] = ENV['TEST_SERVICE_ACCOUNT']

    raise("specify existence test file id") unless @test_existence_file_id and !@test_existence_file_id.empty?
    raise("specify existence test folder id") unless @test_existence_folder_id and !@test_existence_folder_id.empty?
    raise("drive key json file does not exists") unless File.exist?(@key_path)
  end

  after(:context) do
    ENV.delete('GDRIVE_SERVICE_ACCOUNT')
    Fastlane::Actions.clear_lane_context
  end

  context 'when invalid parameter is specified' do
    it 'raise an error if keyfile does not exists' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
        find_google_drive_file_by_id(drive_keyfile: 'test.json')
      end").runner.execute(:test)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "Couldn't find config keyfile at path 'test.json'")
    end

    it 'raise an error if no file_id was given' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
        find_google_drive_file_by_id(drive_keyfile: '#{@key_path}')
      end").runner.execute(:test)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "No `file_id` was given. Pass it using `file_id: 'some_id'`")
    end

    it 'raise an error if empty file_id was given' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          find_google_drive_file_by_id(drive_keyfile: '#{@key_path}', 'file_id': '')
        end").runner.execute(:test)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "No `file_id` was given. Pass it using `file_id: 'some_id'`")
    end
  end

  context 'when finding the file by id is failed' do
    it 'lane_context returns `null` if file_id does not exist' do
      Fastlane::FastFile.new.parse("lane :test do
        find_google_drive_file_by_id(drive_keyfile: '#{@key_path}', file_id: 'some_id')
      end").runner.execute(:test)

      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_FILE_ID]).to be_nil
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_FILE_TITLE]).to be_nil
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_FILE_URL]).to be_nil
    end
  end

  context 'when finding the file by id is succeeded' do
    it 'set lane_context if finding the file by id is succeeded' do
      Fastlane::FastFile.new.parse("lane :test do
        find_google_drive_file_by_id(drive_keyfile: '#{@key_path}', file_id: '#{@test_existence_file_id}')
      end").runner.execute(:test)

      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_FILE_ID]).to eq(@test_existence_file_id)
    end

    it 'set lane_context if finding the folder by id is succeeded' do
      Fastlane::FastFile.new.parse("lane :test do
        find_google_drive_file_by_id(drive_keyfile: '#{@key_path}', file_id: '#{@test_existence_folder_id}')
      end").runner.execute(:test)

      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_FILE_ID]).to eq(@test_existence_folder_id)
    end
  end
end
