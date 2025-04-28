platform :ios, '15.0'

target 'Todoey' do
  use_frameworks!

  pod 'RealmSwift', '~> 5.0'
  pod 'SwipeCellKit'
  pod 'ChameleonFramework' # Instead, 'ChameleonFramework/Swift' showes many build errors.
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
