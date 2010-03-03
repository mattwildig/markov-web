require 'rubygems'
require 'sinatra'
require 'haml'
require 'lib/markov'

before do
  request.env['PATH_INFO'] = '/' if request.env['PATH_INFO'].empty?
end

get '/' do
  @txt = Markov::Chain.new(File.new('data/alice.txt'), :output_words => 600).generate
    
  haml :index
end