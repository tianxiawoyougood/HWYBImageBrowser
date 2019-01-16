#
# Be sure to run `pod lib lint HWYBImageBrowser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HWYBImageBrowser'
  s.version          = '0.1.2'
  s.summary          = '修改YBImageBrowser库完成业务需求'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/tianxiawoyougood/HWYBImageBrowser.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '571100944@qq.com' => '571100944@qq.com' }
  s.source           = { :git => 'https://github.com/tianxiawoyougood/HWYBImageBrowser.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'HWYBImageBrowser/Classes/*.{h,m}', 'HWYBImageBrowser/Classes/VideoBrowse/*.{h,m}', 'HWYBImageBrowser/Classes/Protocol/*.{h,m}', 'HWYBImageBrowser/Classes/ImageBrowse/*.{h,m}', 'HWYBImageBrowser/Classes/Helper/*.{h,m}', 'HWYBImageBrowser/Classes/Base/*.{h,m}', 'HWYBImageBrowser/Classes/AuxiliaryView/*.{h,m}'
  
  s.resources = "HWYBImageBrowser/Assets/YBImageBrowser.bundle"
  #s.resource_bundles = {
  #  'YBImageBrowser' => ['HWYBImageBrowser/Assets/*']
  #}

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  
  s.dependency 'SDWebImage'
  s.dependency 'YYImage'
  s.dependency 'ReactiveObjC'
end
