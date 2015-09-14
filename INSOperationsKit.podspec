Pod::Spec.new do |s|
  s.name         = "INSOperationsKit"
  s.version      = "1.0.1"
  s.summary      = "INSOperationsKit"
  s.license      = 'MIT'
  s.homepage     = "http://inspace.io"
  s.author       = { "Michał Zaborowski" => "m1entus@gmail.com" }
  s.source       = { :git => "https://github.com/inspace-io/INSOperationsKit.git", :tag => "1.0.1" }
  s.requires_arc = true

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.6'

  s.subspec 'Core' do |ss|
    ss.ios.deployment_target = '7.0'
    ss.ios.source_files = 'INSOperationsKit/Shared/**/*.{h,m}', 'INSOperationsKit/iOS/**/*.{h,m}'
    ss.osx.source_files = 'INSOperationsKit/Shared/**/*.{h,m}'
  end

end
