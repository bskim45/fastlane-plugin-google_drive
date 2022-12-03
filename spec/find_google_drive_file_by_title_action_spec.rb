require 'dotenv/load'

describe Fastlane::Actions::FindGoogleDriveFileByTitleAction do
  before(:context) do
    @key_path = File.join(File.dirname(File.dirname(__FILE__)), 'drive_key.json')
    @test_existence_parent_folder_id = ENV['TEST_CHECK_EXISTENCE_PARENT_FOLDER_ID']
    @test_existence_file_id = ENV['TEST_CHECK_EXISTENCE_FILE_ID']
    @test_existence_folder_id = ENV['TEST_CHECK_EXISTENCE_FOLDER_ID']
    @test_existence_file_title = ENV['TEST_CHECK_EXISTENCE_FILE_TITLE']
    @test_existence_folder_title = ENV['TEST_CHECK_EXISTENCE_FOLDER_TITLE']
    ENV['GDRIVE_SERVICE_ACCOUNT'] = ENV['TEST_SERVICE_ACCOUNT']

    raise("specify existence test parent folder id") unless @test_existence_parent_folder_id and !@test_existence_parent_folder_id.empty?
    raise("specify existence test file id") unless @test_existence_file_id and !@test_existence_file_id.empty?
    raise("specify existence test folder id") unless @test_existence_folder_id and !@test_existence_folder_id.empty?
    raise("specify existence test file title") unless @test_existence_file_title and !@test_existence_file_title.empty?
    raise("specify existence test folder title") unless @test_existence_folder_title and !@test_existence_folder_title.empty?
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
          find_google_drive_file_by_title(drive_keyfile: 'test.json')
        end").runner.execute(:test)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "Couldn't find config keyfile at path 'test.json'")
    end

    it 'raise an error if no parent folder id was given' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          find_google_drive_file_by_title(drive_keyfile: '#{@key_path}')
        end").runner.execute(:test)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "No `parent_folder_id` was given. Pass it using `parent_folder_id: 'some_id'`")
    end

    it 'raise an error if empty parent folder id was given' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          find_google_drive_file_by_title(drive_keyfile: '#{@key_path}', parent_folder_id: '')
        end").runner.execute(:test)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "No `parent_folder_id` was given. Pass it using `parent_folder_id: 'some_id'`")
    end

    it 'raise an error if no file_title was given' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          find_google_drive_file_by_title(
            drive_keyfile: '#{@key_path}',
            parent_folder_id: 'some_folder_id'
          )
        end").runner.execute(:test)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "No `file_title` was given. Pass it using `file_title: 'some_title'`")
    end

    it 'raise an error if empty file_title was given' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          find_google_drive_file_by_title(
            drive_keyfile: '#{@key_path}',
            parent_folder_id: 'some_folder_id',
            'file_title': ''
          )
        end").runner.execute(:test)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "No `file_title` was given. Pass it using `file_title: 'some_title'`")
    end
  end

  context 'when finding the file by title is failed' do
    it "raise an error if the parent folder does not exist" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          find_google_drive_file_by_title(
            drive_keyfile: '#{@key_path}',
            parent_folder_id: 'some_folder_id',
            'file_title': 'some_title'
        )
        end").runner.execute(:test)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "File with id 'some_folder_id' not found in Google Drive")

      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_FILE_ID]).to be_nil
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_FILE_TITLE]).to be_nil
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_FILE_URL]).to be_nil
    end

    it "lane_context returns `null` if the file with 'file_title' does not exist" do
      Fastlane::FastFile.new.parse("lane :test do
        find_google_drive_file_by_title(
          drive_keyfile: '#{@key_path}',
          parent_folder_id: '#{@test_existence_parent_folder_id}',
          file_title: 'some_title'
        )
      end").runner.execute(:test)

      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_FILE_ID]).to be_nil
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_FILE_TITLE]).to be_nil
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_FILE_URL]).to be_nil
    end
  end

  context 'when finding the file by title is succeeded' do
    it 'set lane_context if finding the file by title is succeeded' do
      Fastlane::FastFile.new.parse("lane :test do
        find_google_drive_file_by_title(
          drive_keyfile: '#{@key_path}',
          parent_folder_id: '#{@test_existence_parent_folder_id}',
          file_title: '#{@test_existence_file_title}'
        )
      end").runner.execute(:test)

      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_FILE_ID]).to eq(@test_existence_file_id)
    end

    it 'set lane_context if finding the folder by title is succeeded' do
      Fastlane::FastFile.new.parse("lane :test do
        find_google_drive_file_by_title(
          drive_keyfile: '#{@key_path}',
          parent_folder_id: '#{@test_existence_parent_folder_id}',
          file_title: '#{@test_existence_folder_title}'
        )
      end").runner.execute(:test)

      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_FILE_ID]).to eq(@test_existence_folder_id)
    end
  end
end
