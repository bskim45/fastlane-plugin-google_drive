# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/google_drive/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-google_drive'
  spec.version       = Fastlane::GoogleDrive::VERSION
  spec.author        = 'Bumsoo Kim'
  spec.email         = 'bskim45@gmail.com'

  spec.summary       = 'Upload files to Google Drive'
  spec.homepage      = "https://github.com/bskim45/fastlane-plugin-google_drive"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency('google_drive', '~> 3', '>=3.0.7')
  spec.add_dependency('google-apis-drive_v3', '>= 0.5.0', '< 1.0.0')
  spec.add_dependency('google-apis-sheets_v4', '>= 0.4.0', '< 1.0.0')

  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane', '>= 2.140.0')
end
