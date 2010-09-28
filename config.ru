require 'rubygems'

set :app_file,    File.join(File.dirname(__FILE__), 'server.rb')
disable :run, :logging, :dump_errors

run Sinatra::Application
