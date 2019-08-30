#!/usr/bin/env rake
# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Wechat'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rubocop/rake_task'
require File.join('bundler', 'gem_tasks')
require File.join('rspec', 'core', 'rake_task')
RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)

task :default do
  Rake::Task[:spec].invoke
  Rake::Task[:rubocop].invoke
end
