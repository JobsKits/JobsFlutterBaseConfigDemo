Pod::Spec.new do |spec|
  spec.name = 'jobs_rust_ocr'
  spec.version = '0.1.0'
  spec.summary = 'Jobs Rust offline OCR Flutter bridge.'
  spec.homepage = 'https://example.local/JobsRustOCRByPub'
  spec.license = { :type => 'MIT', :file => '../LICENSE' }
  spec.author = { 'Jobs' => 'lg295060456@gmail.com' }
  spec.platform = :ios, '15.1'
  spec.requires_arc = true
  spec.static_framework = true
  spec.source = { :path => '.' }
  spec.source_files = 'Classes/**/*.{h,m}'
  spec.public_header_files = 'Classes/**/*.h'
  spec.frameworks = ['UIKit']
  spec.dependency 'Flutter'
  if File.file?(File.join(__dir__, 'JobsRustOCR', 'JobsRustOCR.podspec'))
    spec.dependency 'JobsRustOCR'
  end
  spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
