require 'dotenv/load'
require 'net/http'

describe Fastlane::Actions::UploadToGoogleDriveAction do
  before(:context) do
    @key_path = File.join(File.dirname(File.dirname(__FILE__)), 'drive_key.json')
    @upload_file = File.join(File.dirname(__FILE__), 'fixtures', 'test_file.txt')
    ENV['GDRIVE_SERVICE_ACCOUNT'] = ENV['TEST_SERVICE_ACCOUNT']

    raise("specify upload test folder id") unless ENV['TEST_UPLOAD_FOLDER_ID'] and !ENV['TEST_UPLOAD_FOLDER_ID'].empty?
    raise("drive key json file does not exists") unless File.exist?(@key_path)
  end

  after(:context) do
    ENV.delete('GDRIVE_SERVICE_ACCOUNT')
    ENV.delete('GDRIVE_KEY_JSON')
    ENV.delete('GDRIVE_KEY_FILE')
    Fastlane::Actions.clear_lane_context
  end

  it 'raise an error if keyfile does not exists' do
    expect do
      Fastlane::FastFile.new.parse("lane :test do
        upload_to_google_drive(drive_keyfile: 'test.json')
      end").runner.execute(:test)
    end.to raise_error(FastlaneCore::Interface::FastlaneError, "Couldn't find config keyfile at path 'test.json'")
  end

  it 'raise an error if given json key is invalid' do
    expect do
      Fastlane::FastFile.new.parse("lane :test do
        upload_to_google_drive(drive_key_json: '')
      end").runner.execute(:test)
    end.to raise_error(FastlaneCore::Interface::FastlaneError, "Provided credential key is not a valid JSON")
  end

  it 'raise an error if json key and keyfile are both provided' do
    expect do
      Fastlane::FastFile.new.parse("lane :test do
        upload_to_google_drive(drive_keyfile: '#{@key_path}', drive_key_json: '{}')
      end").runner.execute(:test)
    end.to raise_error(FastlaneCore::Interface::FastlaneError, "Unresolved conflict between options: 'drive_keyfile' and 'drive_key_json'")
  end

  it 'raise an error if no folder id was given' do
    expect do
      Fastlane::FastFile.new.parse("lane :test do
        upload_to_google_drive(drive_keyfile: '#{@key_path}')
      end").runner.execute(:test)
    end.to raise_error(FastlaneCore::Interface::FastlaneError, "No target `folder_id` was provided. Pass it using `folder_id: 'some_id'`")
  end

  it 'raise an error if no upload file was given' do
    expect do
      Fastlane::FastFile.new.parse("lane :test do
        upload_to_google_drive(drive_keyfile: '#{@key_path}', folder_id: 'some_id', upload_files: [])
      end").runner.execute(:test)
    end.to raise_error(FastlaneCore::Interface::FastlaneError)
  end

  it "raise an error if upload file does not exist" do
    expect do
      Fastlane::FastFile.new.parse("lane :test do
        upload_to_google_drive(drive_keyfile: '#{@key_path}', folder_id: 'some_id', upload_files: ['nofile'])
      end").runner.execute(:test)
    end.to raise_error(FastlaneCore::Interface::FastlaneError, "Couldn't find upload file at path 'nofile'")
  end

  it "raise an error if folder_id does not exist" do
    expect do
      Fastlane::FastFile.new.parse("lane :test do
        upload_to_google_drive(drive_keyfile: '#{@key_path}', folder_id: 'some_id', upload_files: ['#{@upload_file}'])
      end").runner.execute(:test)
    end.to raise_error(FastlaneCore::Interface::FastlaneError, "File with id 'some_id' not found in Google Drive")
  end

  it "raise an error if file upload fails (auth using keyfile - argument)" do
    folder_id = ENV['TEST_UPLOAD_FOLDER_ID']

    Fastlane::FastFile.new.parse("lane :test do
      upload_to_google_drive(drive_keyfile: '#{@key_path}', folder_id: '#{folder_id}', upload_files: ['#{@upload_file}'])
    end").runner.execute(:test)

    expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_UPLOADED_FILE_NAMES]).to eq(['test_file.txt'])
    expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_UPLOADED_FILE_URLS].length).to eq(1)
  end

  it "raise an error if file upload fails (auth using keyfile - GDRIVE_KEY_FILE)" do
    folder_id = ENV['TEST_UPLOAD_FOLDER_ID']
    ENV['GDRIVE_KEY_FILE'] = @key_path

    Fastlane::FastFile.new.parse("lane :test do
      upload_to_google_drive(folder_id: '#{folder_id}', upload_files: ['#{@upload_file}'])
    end").runner.execute(:test)

    expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_UPLOADED_FILE_NAMES]).to eq(['test_file.txt'])
    expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_UPLOADED_FILE_URLS].length).to eq(1)

    ENV.delete('GDRIVE_KEY_FILE')
  end

  it "raise an error if file upload fails (auth using keyfile - GOOGLE_APPLICATION_CREDENTIALS)" do
    folder_id = ENV['TEST_UPLOAD_FOLDER_ID']
    ENV['GOOGLE_APPLICATION_CREDENTIALS'] = @key_path

    Fastlane::FastFile.new.parse("lane :test do
      upload_to_google_drive(folder_id: '#{folder_id}', upload_files: ['#{@upload_file}'])
    end").runner.execute(:test)

    expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_UPLOADED_FILE_NAMES]).to eq(['test_file.txt'])
    expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_UPLOADED_FILE_URLS].length).to eq(1)

    ENV.delete('GOOGLE_APPLICATION_CREDENTIALS')
  end

  it "raise an error if file upload fails (auth using json key - argument)" do
    folder_id = ENV['TEST_UPLOAD_FOLDER_ID']
    drive_key_json = File.read(@key_path)

    Fastlane::FastFile.new.parse("lane :test do
      upload_to_google_drive(drive_key_json: '#{drive_key_json}', folder_id: '#{folder_id}', upload_files: ['#{@upload_file}'])
    end").runner.execute(:test)

    expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_UPLOADED_FILE_NAMES]).to eq(['test_file.txt'])
    expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_UPLOADED_FILE_URLS].length).to eq(1)
  end

  it "raise an error if file upload fails (auth using json key - env)" do
    folder_id = ENV['TEST_UPLOAD_FOLDER_ID']
    ENV['GDRIVE_KEY_JSON'] = File.read(@key_path)

    Fastlane::FastFile.new.parse("lane :test do
      upload_to_google_drive(folder_id: '#{folder_id}', upload_files: ['#{@upload_file}'])
    end").runner.execute(:test)

    expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_UPLOADED_FILE_NAMES]).to eq(['test_file.txt'])
    expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_UPLOADED_FILE_URLS].length).to eq(1)

    ENV.delete('GDRIVE_KEY_JSON')
  end

  it "raise an error if file upload fails or public link generation fails" do
    folder_id = ENV['TEST_UPLOAD_FOLDER_ID']

    Fastlane::FastFile.new.parse("lane :test do
      upload_to_google_drive(drive_keyfile: '#{@key_path}', folder_id: '#{folder_id}', upload_files: ['#{@upload_file}'], public_links: true)
    end").runner.execute(:test)

    expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_UPLOADED_FILE_NAMES]).to eq(['test_file.txt'])
    expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_UPLOADED_FILE_URLS].length).to eq(1)

    Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GDRIVE_UPLOADED_FILE_URLS].each do |url|
      res = Net::HTTP.get_response(URI.parse(url))
      expect(res.code).to eq("200")
    end
  end
end
