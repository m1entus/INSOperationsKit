Pod::Spec.new do |s|
  s.name         = "INSOperationsKit"
  s.version      = "1.0.1"
  s.summary      = "INSOperationsKit"
  s.license      = 'MIT'
  s.homepage     = "http://inspace.io"
  s.author       = { "Michał Zaborowski" => "m1entus@gmail.com" }
  s.source       = { :git => "https://github.com/inspace-io/INSOperationsKit.git", :tag => "1.0.1" }
  s.requires_arc = true
  s.platform = :ios, '7.0'

  s.source_files = 'INSOperationsKit/**/*.{h,m}'
end
