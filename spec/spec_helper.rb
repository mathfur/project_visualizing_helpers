require "rubygems"

require 'simplecov'
require 'simplecov-rcov'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start

require "./lib/project_visualizing_helpers"

BASE_DIR = File.expand_path(File.dirname(__FILE__) + "/..")

DEBUG_BUILD_RUBY_PATH = ENV['DEBUG_BUILD_RUBY_PATH'] or raise "DEBUG_BUILD_RUBY_PATH has to be specified"
unless File.exist?(DEBUG_BUILD_RUBY_PATH) and File.file?(DEBUG_BUILD_RUBY_PATH)
  raise "DEBUG_BUILD_RUBY_PATH `#{DEBUG_BUILD_RUBY_PATH}` does not found."
end

TMP_RUBY_SOURCE = "#{BASE_DIR}/tmp/test_target.rb"
TMP_PYTHON_SOURCE = "#{BASE_DIR}/tmp/test_target.py"
