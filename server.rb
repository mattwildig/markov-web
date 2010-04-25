require 'rubygems'
require 'sinatra'
require 'haml'
# require 'lib/markov'
require 'lib/data'
require 'ext/Markov'

MAX_WORDS = 1000

# set :haml, {:format => :html5 }

before do
  request.env['PATH_INFO'] = '/' if request.env['PATH_INFO'].empty?
end

get '/' do
  
  params['numwords'] = [(params['numwords'] && params['numwords'].to_i > 0 && params['numwords'].to_i) || 600, MAX_WORDS].min
  
  if params['data']
    files = params['data'].collect do |s|
      begin
        File.new(File.join('data', "#{s}.txt" ))
      rescue Errno::ENOENT
        nil
      end
    end
    
    files.compact!
    
    #@txt = Markov::Chain.new(files, :output_words => params['numwords']).generate
    @txt = Markov.new.add_input(files[0]).generate_string
    
    files.each{|f| f.close}
  end
  haml :index
end