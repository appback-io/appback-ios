#
# Be sure to run `pod lib lint AppBack.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AppBack'
  s.version          = '1.0'
  s.summary          = 'AppBack client'
  s.description      = <<-DESC
  Easy way to implement AppBack.io API using an iOS app with swift
                       DESC

  s.homepage         = 'https://github.com/appback-io/appback-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'appback' => 'support@appback.io' }
  s.source           = { :git => 'https://github.com/appback-io/appback-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.ios.deployment_target = '8.0'
  s.source_files = 'Classes/**/*'
  s.frameworks       = 'SystemConfiguration', 'CoreTelephony'
  s.swift_version    = '4.0'
end
