#
# Be sure to run `pod lib lint ScanCode.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ScanCode'
  s.version          = '1.0.7'
  s.summary          = 'IOS qrcode and barcode scan'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = <<-DESC
  IOS qrcode and barcode scan(IOS版的二维码和条码扫描识别)
                       DESC

  s.homepage         = 'https://github.com/Dazhi528/ScanCode'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dazhi528' => 'wzz528@icloud.com' }
  s.source           = { :git => 'https://github.com/Dazhi528/ScanCode.git', :tag => s.version.to_s }


  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => ['i386','x86_64'] }
 
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.source_files = 'ScanCode/Classes/**/*'
  
  s.resources = ['ScanCode/Assets/**/*']

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
