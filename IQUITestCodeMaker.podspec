Pod::Spec.new do |s|
  s.name         = "IQUITestCodeMaker"
  s.version      = "1.0.0"
  s.summary      = "IQUITestCodeMaker is a strong tool kit for generating script code without lanuching appium desktop or using inspector."
  s.homepage     = "https://github.com/Lobster-King/IQUITestCodeMaker/wiki/IQUITestCodeMaker-Documents"
  s.license      = "MIT"
  s.authors      = { 'lobster' => 'zhiwei.geek@gmail.com'}
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Lobster-King/IQUITestCodeMaker.git", :tag => s.version }
  s.source_files = 'IQUITestCodeMaker', 'IQUITestCodeMaker/**/*.{h,m}'
  s.requires_arc = true
  s.dependency   = 'GCDWebServer'
end
