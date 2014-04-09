version = File.read(File.expand_path('../VERSION', __FILE__)).strip

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.author       = 'Skinnyworm'
  s.email        = 'askinnyworm@gmail.com'
  s.homepage     = 'https://github.com/skinnyworm/wechat-rails'

  s.name        = "wechat-rails"
  s.version     = version
  s.summary     = "DSL for wechat message handling and api"
  s.description = "API and message handling for wechat in rails environment"

  s.files = Dir["{bin app,config,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.executables << 'wechat'

  s.add_dependency "rails", ">= 3.2.14"
  s.add_dependency "nokogiri", '>=1.6.0'
  s.add_dependency 'rest-client'
  s.add_development_dependency 'rspec-rails'
end
