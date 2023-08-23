#
# Be sure to run `pod lib lint UserKVStorage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UserKVStorage'
  s.version          = '0.1.0'
  s.summary          = 'UserKVStorage'
  s.description      = <<-DESC
  `基于MMKV封装`
                       DESC
  s.homepage         = 'https://github.com/arcangel-w/UserKVStorage'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'arcangel-w' => 'wuzhezmc@gmail.com' }
  s.source           = { :git => 'https://github.com/arcangel-w/UserKVStorage.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.13"
  s.tvos.deployment_target = "13.0"

  s.source_files = 'UserKVStorage/Classes/**/*.swift'
  s.frameworks = 'Foundation'
  s.dependency 'MMKV', '~> 1.3.1'
end
