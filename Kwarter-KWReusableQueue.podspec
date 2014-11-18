Pod::Spec.new do |s|
  s.name     = 'Kwarter-KWReusableQueue'
  s.version  = '1.0'
  s.license  = 'MIT'
  s.summary  = 'Class to store objects in a reusable queue to minimize memory allocations for better efficiency.'
  s.homepage = 'https://github.com/kwarter/KWReusableQueue'
  s.authors  = 'Glenn Chiu'
  s.source   = { :git => 'https://github.com/kwarter/KWReusableQueue.git', :tag => '1.0' }
  s.source_files = 'KWReusableQueue/'
  s.requires_arc = true
  s.ios.deployment_target = '4.3'
  s.osx.deployment_target = '10.6'
end