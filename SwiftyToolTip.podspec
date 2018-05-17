#
# Be sure to run `pod lib lint SwiftyToolTip.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftyToolTip'
  s.version          = '0.0.1'
  s.summary          = 'Add a tooltip to any UIView or subclass with just a single line of code'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
With just 1 line of code you can add a tooltip to any UIView or subclass describing the functionality or content of that view. Add description for the action of buttons or show your user exactly what is displayed in a certain view.
                       DESC

  s.homepage         = 'https://github.com/BobDeKort/SwiftyToolTip'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'BobDeKort' => 'dekort.bob101@gmail.com' }
  s.source           = { :git => 'https://github.com/BobDeKort/SwiftyToolTip.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'SwiftyToolTip/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SwiftyToolTip' => ['SwiftyToolTip/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
