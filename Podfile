source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '12.0'
use_frameworks!
inhibit_all_warnings!

target 'Bonjour' do
  pod 'IQKeyboardManagerSwift'
  pod 'Alamofire'
  pod 'SnapKit', '~> 5.0.0'
  pod 'AlamofireEasyLogger'
  pod 'FTIndicator'
  pod 'SwiftLint'
  pod 'Nuke'
  pod 'ESPullToRefresh'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
        config.build_settings['LD_NO_PIE'] = 'NO'
      end
    end
  end

  target 'BonjourTests' do
    inherit! :search_paths
    # Pods for testing
  end
end

