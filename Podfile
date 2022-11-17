# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

def common_pods
  pod 'R.swift'
  pod 'SwiftLint'
  pod 'BrightFutures'
  pod 'ObjectMapper'
  pod 'Alamofire'
  pod 'Kingfisher', '~> 7.0'
  pod 'AARatingBar'
  pod 'VersaPlayer'
end

target 'VideoFeedClient' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  common_pods
  # Pods for VideoClient
  
  target 'VideoFeedClientTests' do
    inherit! :search_paths
    # Pods for testing
    common_pods
  end
  
  target 'VideoFeedClientUITests' do
    # Pods for testing
    common_pods
  end
  
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
    end
  end
end
