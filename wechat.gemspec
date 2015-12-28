version = File.read(File.expand_path('../VERSION', __FILE__)).strip

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.authors     = ['Skinnyworm', 'Eric Guo']
  s.email       = 'eric.guocz@gmail.com'
  s.homepage    = 'https://github.com/Eric-Guo/wechat'

  s.name        = 'wechat'
  s.version     = version
  s.licenses    = ['MIT']
  s.summary     = 'DSL for wechat message handling and API'
  s.description = 'API and message handling for WeChat in Rails'

  s.files = Dir['{bin,lib}/**/*'] + %w(LICENSE Rakefile README.md README-CN.md CHANGELOG.md)
  s.executables << 'wechat'

  s.post_install_message = %Q(*****WECHAT BREAK CHANGE*****
1. Scan 2D barcode using new syntax `on :scan, with: 'BINDING_QR_CODE' `
instead of previous `on :event, with: 'BINDING_QR_CODE' `.
2. Batch job using new syntax `on :batch_job, with: 'replace_user' `
instead of previous `on :event, with: 'replace_user' `.
*****************************)

  s.add_runtime_dependency 'activesupport', '>= 3.2', '< 5.1.x'
  s.add_runtime_dependency 'nokogiri', '>=1.6.0'
  s.add_runtime_dependency 'thor'
  s.add_runtime_dependency 'http', '>= 1.0.1'
  s.add_development_dependency 'rspec-rails', '~> 3.4'
  s.add_development_dependency 'rails', '>= 3.2'
end
