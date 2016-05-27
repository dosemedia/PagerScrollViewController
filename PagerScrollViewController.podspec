#
# Be sure to run `pod lib lint PagerScrollViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PagerScrollViewController'
  s.version          = '0.1.0'
  s.summary          = 'UIScrollView Extension for paging UIViewControllers'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
PagerScrollViewController is a UIScrollView extension that allows for paging UIViewControllers efficently. Similar to Android's implementation of ViewPager and Fragments.
                       DESC

  s.homepage         = 'https://github.com/dosemedia/PagerScrollViewController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Michael Blatter' => 'mblatter@dose' }
  s.source           = { :git => 'https://github.com/dosemedia/PagerScrollViewController.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'PagerScrollViewController/Classes/**/*'
end
