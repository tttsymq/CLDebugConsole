Pod::Spec.new do |s|
  s.name         = 'CLDebugConsole'
  s.version      = '1.0.2'
  s.summary      = 'A modular floating debug console for iOS applications'
  s.description  = <<-DESC
    CLDebugConsole provides a floating debug toolbar with pluggable modules.
    Features include floating icon with edge snapping, multi-plugin support,
    logging system with storage/filtering/export, and extensible architecture.
  DESC

  s.homepage     = 'https://github.com/tttsymq/CLDebugConsole'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Your Name' => 'your.email@example.com' }
  s.source       = { :git => 'https://github.com/tttsymq/CLDebugConsole.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.requires_arc = true

  s.default_subspecs = 'Core', 'LogPlugin'

  s.subspec 'Core' do |core|
    core.source_files = 'CLDebugConsole/Core/**/*.{h,m}', 'CLDebugConsole/UI/**/*.{h,m}', 'CLDebugConsole/Utils/**/*.{h,m}'
    core.public_header_files = 'CLDebugConsole/Core/**/*.h', 'CLDebugConsole/UI/**/*.h', 'CLDebugConsole/Utils/**/*.h'
    core.resource_bundles = {
      'CLDebugConsole' => ['CLDebugConsole/Resources/**/*']
    }
    core.frameworks = 'UIKit', 'Foundation'
  end

  s.subspec 'LogPlugin' do |log|
    log.source_files = 'CLDebugConsole/Plugins/Log/**/*.{h,m}'
    log.public_header_files = 'CLDebugConsole/Plugins/Log/**/*.h'
    log.dependency 'CLDebugConsole/Core'
  end
end
