#
# Be sure to run `pod lib lint ScrollViewThumbnail.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ScrollViewThumbnail'
  s.version          = '0.1.0'
  s.summary          = 'Quickly create thumbnails for zoomed views in UIScrollview.'
  s.description      = <<-DESC
  Quickly create thumbnails for zoomed views in UIScrollview with just a single line of code.
  DESC

  s.homepage         = 'https://github.com/TBXark/ScrollViewThumbnail'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'TBXark' => 'tbxark@outlook.com' }
  s.source           = { :git => 'https://github.com/TBXark/ScrollViewThumbnail.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'ScrollViewThumbnail/Classes/**/*'
end
