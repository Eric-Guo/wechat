# frozen_string_literal: true

Gem::Specification.new do |s|
  s.authors     = ['Skinnyworm', 'Eric Guo']
  s.email       = 'eric.guocz@gmail.com'
  s.homepage    = 'https://github.com/Eric-Guo/wechat'

  s.name        = 'wechat'
  s.version     = File.read(File.expand_path('VERSION', __dir__)).strip
  s.licenses    = ['MIT']
  s.summary     = 'DSL for wechat message handling and API'
  s.description = 'API, command and message handling for WeChat in Rails'
  s.required_ruby_version = '~> 2.3'

  s.files = Dir['{bin,lib}/**/*'] + %w[LICENSE README.md README-CN.md CHANGELOG.md]
  s.executables << 'wechat'

  s.cert_chain  = ['certs/Eric-Guo.pem']
  s.signing_key = File.expand_path('~/.ssh/gem-private_key.pem') if $PROGRAM_NAME.end_with?('gem')

  s.add_runtime_dependency 'activesupport', '>= 3.2', '<= 5.2'
  s.add_runtime_dependency 'http', '>= 1.0.4', '< 4'
  s.add_runtime_dependency 'nokogiri', '>=1.6.0'
  s.add_runtime_dependency 'thor'
  s.add_development_dependency 'rails', '>= 5.1'
  s.add_development_dependency 'rspec-rails', '~> 3.6'
  s.add_development_dependency 'sqlite3'
end
