# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'WavesWallet-iOS' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for WavesWallet-iOS
  pod 'RxSwift', '~> 3.4'
  pod 'RxCocoa', '~> 3.4'
  pod 'RxDataSources', '~> 1.0'
  pod 'RxAlamofire'
  pod 'SwiftyJSON'
  pod 'Gloss', '2.0.0-beta.1'
  pod 'RealmSwift', '~> 2.10.0'
  pod 'RxRealm', '~> 0.6'
  pod 'MGSwipeTableCell'
  pod '25519', '~> 2.0.2'
  pod 'KeychainAccess'
  pod 'MBProgressHUD', '~> 1.0.0'
  pod 'IQKeyboardManagerSwift'
  pod 'RxGesture'
  pod 'UITextView+Placeholder'
  pod 'QRCode'
  pod 'UILabel+Copyable', '~> 1.0.0'
  pod 'QRCodeReader.swift', '~> 7.5.1'
  pod 'TPKeyboardAvoiding'
  pod 'SVProgressHUD'
  pod 'RDVTabBarController'
  pod 'RESideMenu', :git => 'https://github.com/florianbuerger/RESideMenu.git'
  pod 'Charts'
  pod 'UPCarouselFlowLayout'
  pod 'SwipeView'
  pod 'TTTAttributedLabel'
  pod 'Koloda'

  post_install do |installer|

#https://github.com/CocoaPods/CocoaPods/issues/7606
#      installer.pods_project.build_configurations.each do |config|
#          config.build_settings.delete('CODE_SIGNING_ALLOWED')
#          config.build_settings.delete('CODE_SIGNING_REQUIRED')
#      end

      installer.pods_project.targets.each do |target|
          if target.name == 'Charts'
              target.build_configurations.each do |config|
                  config.build_settings['SWIFT_VERSION'] = '4.1'
              end
          end
      end
  end
  
  
end

