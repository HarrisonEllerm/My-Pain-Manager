# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'MPM-Sft-Eng-Proj' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # ignore all warnings from all pods
  # employed as some pods use deprecated stuff.
  inhibit_all_warnings!

  # Pods for MPM-Sft-Eng-Proj
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'Firebase/Storage'
    pod 'LBTAComponents'
    pod 'JGProgressHUD'
    pod 'SwiftyJSON'
    pod 'SwiftValidator', :git => 'https://github.com/jpotts18/SwiftValidator.git', :branch => 'master'
    pod 'GoogleSignIn'
    pod 'Charts'
    pod 'ChartsRealm'

  target 'MPM-Sft-Eng-ProjTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MPM-Sft-Eng-ProjUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
