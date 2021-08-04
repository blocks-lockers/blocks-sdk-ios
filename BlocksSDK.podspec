Pod::Spec.new do |s|
  
s.name         = "BlocksSDK"
s.version      = "1.0.1"
s.summary      = "A Blocks Lockers SDK for API communication and opening doors via bluetooth"

s.homepage     = "https://github.com/blocks-lockers/blocks-sdk-ios"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author       = { "alex-alex" => "alex.studnicka@blockslockers.com" }

s.ios.deployment_target = "11.0"
s.swift_version = "5.3"

s.source        = { :git => "https://github.com/blocks-lockers/blocks-sdk-ios.git", :tag => "#{s.version}" }
s.source_files  = "Sources/**/*.{h,m,swift}"

s.dependency 'Alamofire', '5.4.0'

end
