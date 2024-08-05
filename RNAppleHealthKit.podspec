require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name             = 'react-native-health'
  s.version          = package['version']
  s.summary          = package['description']
  s.license          = package['license']
  s.authors          = package['author']
  s.homepage         = package['homepage']
  s.source           = { :git => package['repository']['url'], :tag => "#{s.version}" }

  s.ios.deployment_target = '13.0'
  s.swift_version         = '5.0'

  s.description      = <<-DESC
A React Native package to interact with Apple HealthKit
  DESC

  s.source_files = 'RCTAppleHealthKit/**/*', 'ios/**/*.{h,m,swift}'

  s.frameworks = ['HealthKit']
  s.dependency 'React'
end
