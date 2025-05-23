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
  s.post_install_message = "\nBREAKING changes: WECHAT_PROXY_URL should be written with port now, like `export WECHAT_PROXY_URL=http://127.0.0.1:6152`, since WECHAT_PROXY_PORT removed.\n"
  s.required_ruby_version = '>= 2.7'
  s.required_rubygems_version = ">= 3.1.6"

  s.files = Dir['{bin,lib}/**/*'] + %w[LICENSE README.md README-CN.md CHANGELOG.md]
  s.executables << 'wechat'

  s.cert_chain  = ['certs/Eric-Guo.pem']
  s.signing_key = File.expand_path('~/.ssh/gem-private_key.pem') if $PROGRAM_NAME.end_with?('gem')

  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/Eric-Guo/wechat/issues',
    'changelog_uri' => 'https://github.com/Eric-Guo/wechat/releases',
    'documentation_uri' => "https://github.com/Eric-Guo/wechat/tree/v#{s.version}#readme",
    'source_code_uri' => "https://github.com/Eric-Guo/wechat/tree/v#{s.version}",
    'rubygems_mfa_required' => 'true'
  }

  s.add_runtime_dependency 'activesupport', '>= 6.0', '< 9'
  s.add_runtime_dependency 'httpx', '>= 1.3.4'
  s.add_runtime_dependency 'nokogiri', '>= 1.6.0'
  s.add_runtime_dependency 'ostruct'
  s.add_runtime_dependency 'thor'
  s.add_runtime_dependency 'rexml'
  s.add_runtime_dependency 'zeitwerk', '~> 2.4'

  s.add_development_dependency 'rubocop', '~> 1.72.2'
  s.add_development_dependency 'rails', '>= 7.2'
  s.add_development_dependency 'rspec-rails', '~> 7.1'
  s.add_development_dependency 'rspec-mocks', '~> 3.13'
  s.add_development_dependency 'sqlite3', '~> 2.0'
end
