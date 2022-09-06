Pod::Spec.new do |s|
  s.name         = "INSOperationsKit"
  s.version      = "1.5.0"
  s.summary      = "INSOperationsKit"
  s.license      = 'MIT'
  s.homepage     = "http://inspace.io"
  s.author       = { "Michał Zaborowski" => "m1entus@gmail.com" }
  s.source       = { :git => "https://github.com/m1entus/INSOperationsKit.git", :tag => "1.5.0" }
  s.requires_arc = true

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'

  s.ios.source_files = 'INSOperationsKit/Shared/**/*.{h,m}', 'INSOperationsKit/iOS/**/*.{h,m}', 'INSOperationsKit/INSOperationsKit.h'
  s.osx.source_files = 'INSOperationsKit/Shared/**/*.{h,m}'
  s.tvos.source_files = 'INSOperationsKit/Shared/**/*.{h,m}'
end
