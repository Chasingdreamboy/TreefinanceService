#
# Be sure to run `pod lib lint TreefinanceService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TreefinanceService'
  s.version          = '0.0.14'
  s.summary          = 'Use for get information in backgroud'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/acct<blob>=<NULL>/TreefinanceService'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'acct<blob>=<NULL>' => 'wangerdong@treefinance.com.cn' }
  s.source           = { :git => 'https://github.com/Chasingdreamboy/TreefinanceService.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
s.platform = :ios
  s.ios.deployment_target = '8.0'

  s.source_files = 'TreefinanceService/Classes/**/*'
  s.requires_arc = 'TreefinanceService/Classes/Arc/**/*'
   s.resource_bundles = {
     'TreefinanceService' => ['TreefinanceService/Assets/*.png','TreefinanceService/Assets/*.xml','TreefinanceService/Assets/*.js','TreefinanceService/Assets/*.html','TreefinanceService/Assets/*.gif']
   }

   s.public_header_files = 'TreefinanceService/Classes/**/*.h'
   s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'AFNetworking', '~> 3.1.0'
   s.dependency 'MJRefresh', '~> 3.1.12'
   s.dependency 'SDWebImage', '~> 4.0.0'
   s.dependency 'RegexKitLite', '~> 4.0'
   s.dependency 'MBProgressHUD', '~> 1.0.0'
   s.dependency 'FCCurrentLocationGeocoder', '~> 1.1.11'
   s.dependency 'OpenUDID', '~> 1.0.0'
   s.dependency 'NYXImagesKit', '~> 2.3'
   s.dependency 'NJKWebViewProgress', '~> 0.2.3'
   s.dependency 'GTMBase64', '~> 1.0.0'
   s.dependency 'SimpleExif', '~> 0.0.1'
   s.dependency 'RKDropdownAlert', '~> 0.3.0'
   #s.dependency 'FCIPAddressGeocoder', '~> 1.2.0'
end
