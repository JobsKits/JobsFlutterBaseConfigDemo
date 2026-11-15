Pod::Spec.new do |spec|
  spec.name = 'jobs_platform_lab'
  spec.version = '0.1.0'
  spec.summary = 'Jobs Flutter native platform laboratory.'
  spec.description = 'ARKit, Bluetooth, CoreMotion, recording and system services for Jobs Flutter demos.'
  spec.homepage = 'https://github.com/JobsKits/JobsFlutterBaseConfigDemo'
  spec.license = { :type => 'MIT', :file => '../LICENSE' }
  spec.author = { 'Jobs' => 'jobs@users.noreply.github.com' }
  spec.source = { :path => '.' }
  spec.source_files = 'Classes/**/*'
  spec.dependency 'Flutter'
  spec.dependency 'HaishinKit', '2.0.9'
  spec.platform = :ios, '15.0'
  spec.swift_version = '5.0'
  spec.frameworks = [
    'ARKit',
    'SceneKit',
    'CoreBluetooth',
    'CoreMotion',
    'AVFoundation',
    'AVKit',
    'Photos',
    'WidgetKit',
    'PDFKit'
  ]
  spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
