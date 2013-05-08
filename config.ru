require 'bundler'
Bundler.require(:default)
require File.expand_path('../app.rb', __FILE__)
run Locksmith::App
