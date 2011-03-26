require 'rubygems'
require 'sinatra'
require 'haml'
require 'markov'

require './data'

MAX_WORDS = 1000
DEFAULT_WORDS = 600

get '/?' do
  numwords = params['numwords'] ? params['numwords'].to_i : DEFAULT_WORDS
  numwords = numwords >= 0 ? numwords : DEFAULT_WORDS
  numwords = [numwords, MAX_WORDS].min
    
  @native = params['impl'] == 'native'
  
  impl = @native ? Markov::ChainNative : Markov::Chain
  
  if params['data']
    files = params['data'].collect do |s|
      begin
        File.new(File.join('data', "#{s}.txt" ))
      rescue Errno::ENOENT
      end
    end
    
    files.compact!
    
    start = Time.new
    @txt = impl.new(files, :output_words => numwords).generate
    final = Time.new
    
    files.each{|f| f.close}
    
    @time = final.to_f - start.to_f
  end
  haml :index
end