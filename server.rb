require 'rubygems'
require 'sinatra'
require 'haml'
require 'lib/markov'

get '/' do
  @txt = Markov::Chain.new(File.new('data/alice.txt'), :output_words => 600).generate
    
  haml :index
end