Pod::Spec.new do |s|
  s.name             = 'ScreenRotator'
  s.version          = '0.1.0'
  s.summary          = 'A utility class that allows for changing/maintaining screen orientation programmatically.'
  
  s.description      = <<-DESC
  A utility class that allows for changing/maintaining screen orientation programmatically.
                       DESC

  s.homepage         = 'https://github.com/Rogue24/ScreenRotator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rogue24' => 'zhoujianping24@hotmail.com' }
  s.source           = { :git => 'https://github.com/Rogue24/ScreenRotator.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '11.0'

  s.source_files = 'ScreenRotator/*.{h,m}', 'ScreenRotator/*.swift'
  
  s.swift_version = '5.0'
  
end