require 'rubygems'
require 'sinatra'
require 'haml'
require 'markov'

require './data'

if (RUBY_VERSION == '1.9.2' && __FILE__ == $0 && Sinatra::VERSION =~ /^1.0/)
  enable :run
  set :views, File.dirname(__FILE__) + "/views" 
end

MAX_WORDS = 1000
DEFAULT_WORDS = 600

before do
  request.env['PATH_INFO'] = '/' if request.env['PATH_INFO'].empty?
end

get '/' do
  
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
        nil
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