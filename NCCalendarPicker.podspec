
Pod::Spec.new do |s|

  s.name          = "NCCalendarPicker"
  s.version       = "0.0.2"
  s.summary       = "Public"
  s.description   = <<-DESC
                    日期选择器SDK
                    DESC
  s.homepage      = "https://github.com/xiaoyeZhang/NCCalendarPicker.git"
  s.license       = "MIT"
  s.author        = { "张晓烨" => "82387913@qq.com" }
  s.platform      = :ios, "11.0"
  s.swift_version = '5.0'
  s.source        = { :git => "https://github.com/xiaoyeZhang/NCCalendarPicker.git", :tag => "#{s.version}" }
  s.source_files  = "Sources","Sources/**/*.swift"
  s.exclude_files = "Sources/Exclude"
  s.user_target_xcconfig = {
    'GENERATE_INFOPLIST_FILE' => 'YES'
  }
  s.pod_target_xcconfig = {
    'GENERATE_INFOPLIST_FILE' => 'YES'
  }
  s.frameworks    = "UIKit", "Foundation"
  s.dependency   "SnapKit"
end
