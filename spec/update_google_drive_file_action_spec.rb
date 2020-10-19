require 'dotenv/load'
require 'time'

describe Fastlane::Actions::UpdateGoogleDriveFileAction do
  before(:context) do
    @key_path = File.join(File.dirname(File.dirname(__FILE__)), 'drive_key.json')
    raise("specify update test file id") unless ENV['TEST_UPDATE_FILE_ID'] and !ENV['TEST_UPDATE_FILE_ID'].empty?
    raise("drive key json file does not exists") unless File.exist?(@key_path)
  end

  before(:each) do
    ENV['GDRIVE_SERVICE_ACCOUNT'] = ENV['TEST_SERVICE_ACCOUNT']
  end

  after(:each) do
    ENV.delete('GDRIVE_SERVICE_ACCOUNT')
  end

  it 'raise an error if keyfile does not exists' do
    expect do
      Fastlane::FastFile.new.parse("lane :test do
        update_google_drive_file(drive_keyfile: 'test.json')
      end").runner.execute(:test)
    end.to raise_error(FastlaneCore::Interface::FastlaneError, "Couldn't find config keyfile at path 'test.json'")
  end

  it 'raise an error if no file id was given' do
    expect do
      Fastlane::FastFile.new.parse("lane :test do
        update_google_drive_file(drive_keyfile: '#{@key_path}')
      end").runner.execute(:test)
    end.to raise_error(FastlaneCore::Interface::FastlaneError, "No target file id given, pass using `file_id: 'some_id'`")
  end

  it 'raise an error if no upload file was given' do
    expect do
      Fastlane::FastFile.new.parse("lane :test do
        update_google_drive_file(drive_keyfile: '#{@key_path}', file_id: 'some_id')
      end").runner.execute(:test)
    end.to raise_error(FastlaneCore::Interface::FastlaneError)
  end

  it "raise an error if local file does not exist" do
    expect do
      Fastlane::FastFile.new.parse("lane :test do
        update_google_drive_file(drive_keyfile: '#{@key_path}', file_id: 'some_id', upload_file: 'nofile')
      end").runner.execute(:test)
    end.to raise_error(FastlaneCore::Interface::FastlaneError, "Couldn't find upload file at path 'nofile'")
  end

  it "raise an error if file_id does not exist" do
    expect do
      file = Tempfile.new('test_file_update.txt')
      begin
        Fastlane::FastFile.new.parse("lane :test do
          update_google_drive_file(drive_keyfile: '#{@key_path}', file_id: 'some_id', upload_file: '#{file.path}')
        end").runner.execute(:test)
      ensure
        file.delete
      end
    end.to raise_error(FastlaneCore::Interface::FastlaneError, "File with id 'some_id' not found in Google Drive")
  end

  it "raise an error if file upload fails" do
    file_id = ENV['TEST_UPDATE_FILE_ID']

    file = Tempfile.new('test_file_update.txt')
    begin
      file.puts(Time.now.utc.iso8601)
      file.close

      Fastlane::FastFile.new.parse("lane :test do
        update_google_drive_file(drive_keyfile: '#{@key_path}', file_id: '#{file_id}', upload_file: '#{file.path}')
      end").runner.execute(:test)
    ensure
      file.delete
    end

    expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_UPDATED_FILE_NAME]).to eq('test_file_update.txt')
  end
end
