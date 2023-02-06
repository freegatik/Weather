platform :ios, '18.4'

target 'Weather' do
  use_frameworks!

  pod 'SDWebImage', '~> 5.21.0', :inhibit_warnings => true

  target 'WeatherTests' do
    inherit! :search_paths
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        if target.name == 'SDWebImage'
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.4'
        end
        config.build_settings['GCC_WARN_DEPRECATED_FUNCTIONS'] = 'NO'
        config.build_settings['CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS'] = 'NO'
      end
    end
  end
end