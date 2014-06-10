
lib = File.expand_path(File.dirname(__FILE__) + '/../bin')
$LOAD_PATH.unshift(lib) if File.directory?(lib) && !$LOAD_PATH.include?(lib)

require 'wechat'